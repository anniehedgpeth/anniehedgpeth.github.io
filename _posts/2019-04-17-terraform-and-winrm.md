---
layout: post
title:  "Terraform + Azure + WinRM"
date:   2019-04-17 12:00:00
categories: azure, terraform, winrm, kerberos, ntlm, dns, ca cert, group policy, active directory
tags: azure, terraform, winrm, kerberos, ntlm, dns, ca cert, group policy, active directory
image: /assets/article_images/2019-04-17-terraform-and-winrm/terraform-and-winrm.jpg
image2: /assets/article_images/2019-04-17-terraform-and-winrm/terraform-and-winrm-mobile.jpg
---
Walk with me for a moment if you will. Let's say you need to spin up a Windows 2016 node in Terraform that has to join the Active Directory domain. And then you need to be able to WinRM into that node during your Terraform run, because let's say you need to add a remote_exec provisioner that does something that you can only do as a domain account user on the domain, and it has to happen within Terraform for whatever reason. Let's also say that your Group Policy is super strict, and there's no changing it.

*Acceptance Criteria:*
Be able to WinRM into a Windows Server 2016 with Terraform from a Shared Image Gallery image

*Challenges:*

1. The node being provisioned needs to be on the domain.
2. There is an Active Directory Group Policy requiring that WinRM be authorized via Kerberos or NTLM
3. Only a domain account user can make the request to the CA
4. You have to WinRM over HTTPS as a domain account user.

## TL;DR Steps

1. Create your virtual machine
2. Join the domain
3. Run a custom script extension that does all the work
4. Now you can WinRM

```hcl
resource "azurerm_virtual_machine" "self" {}
resource "azurerm_virtual_machine_extension" "join-domain" {}
resource "azurerm_virtual_machine_extension" "custom-script" {}
resource "null_resource" "remote_exec" {}
```

## The wordy instructions

So let's talk about this...I'll assume you've already created the first two steps (see TL;DR above) in Terraform. Step 3 is where we'll hang out for a bit.

The way you configure WinRM to run over HTTPS is by [importing a certificate](https://www.thewindowsclub.com/manage-trusted-root-certificates-windows) and then creating a "WinRM listener" that is authenticated by that certificate. Assuming you've gotten your certificate, all you do for that is add this line to your `winrm config`, and you can add it simply by running this in Powershell:

```powershell
# Get the thumbprint of the certificate first. You may have to add more criteria to narrow it down if there are others w/hostname in the name.
$thumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "$hostname").Thumbprint

# Create a listener that uses that thumbprint.
winrm create winrm/config/Listener?Address=IP:$ip+Transport=HTTPS "@{Hostname=`"$hostname`"; CertificateThumbprint=`"$thumbprint`"}"
```

Great, right? Let's get that certificate and get moving.

Oh wait...you can't just use a random self-signed certificate spun up in Key Vault. No, your Group Policy mandates that the certificate be signed by the Certificate Authority (CA) and that the CA be your company, let's call it "Fireside, Inc". Okay, so you'll need to request a certificate from Fireside, Inc. with a Powershell script like [this](https://github.com/J0F3/PowerShell/blob/master/Request-Certificate.ps1) or [this](https://4sysops.com/archives/create-a-certificate-request-with-powershell). Oh, but only a domain account user can make the request to the CA (per the Group Policy). So how do I make the request to the CA as a domain user if Terraform only runs as the local user I just created? Well, this is tricky. You _can_ run as another user, but we have to do some work to get there first given the contraints of your AD Group Policy. You will have to run in an elevated shell, which Terraform doesn't do on its own, so let's see how we can make this happen for you.

## How to run in an elevated shell

You want to run as the local admin (non-domain account) that has permission to run as a domain user with its credentials, but in order to do that you need to be in an elevated shell.  For that we go to none other than the go-to-Windows-WinRM-guru, [Matt Wrock](http://www.hurryupandwait.io/). In an `azurerm_virtual_machine_extension` which runs as the non-domain local admin user you'll call [Matt Wrock's Powershell script](https://github.com/WinRb/winrm-elevated/blob/master/lib/winrm-elevated/scripts/elevated_shell.ps1) called `elevated_shell.ps1`. (He created this script as part of a gem called `winrm-elevated`, which you can also use, but we didn't.)

There is a parameter in that script called `$script` which is the script that you want run in the evelated shell. You may need to add your domain account user at this point, so in the beginning of Matt's script go ahead and add add a one-liner to add your domain user to the administrators group on the machine. Then the script creates a task to allow you to run `$script` as the elevated shell which allows you to run as the domain user. As long as that domain user is in the Administrator's group on the machine you are provisioning, it should have the required access rights. Your `$script` parameter will be another script that you create called `setupWinRm.ps1` that requests a the certificate from the Certificate Authority (CA) as the domain user. Then it will configure WinRM for HTTPS on 5986 with that certificate and opened the firewall for HTTPS. That process enables WinRM for HTTPS through Kerberos or NTLM authentication.

Your Terraform block will look something like this:

```go

resource "azurerm_virtual_machine_extension" "custom-script" {
 # < all the arguments here >

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell .\\elevated_shell.ps1 -Script (Resolve-Path .\\setupWinRm.ps1) -Username ${var.active_directory_domain}\\${var.vm_domain_user} -Password ${var.vm_domain_password}",
        "fileUris" : ["https://yourbloborwhereveryoukeepyourscripts/elevated_shell.ps1", "https://yourbloborwhereveryoukeepyourscripts/setupWinRm.ps1"]
     }
  SETTINGS

  depends_on = ["azurerm_virtual_machine_extension.join-domain"]
}
```

See above that your `commandToExecute` has `setupWinRm.ps1` as the `$script` parameter and that you're grabbing TWO files from blob or wherever to put onto the node, your altered `elevated_shell.ps1` and your `setupWinRm.ps1`.

Your `setupWinRm.ps1` will look different depending upon your needs, but first you'll request the cert like [this](https://github.com/J0F3/PowerShell/blob/master/Request-Certificate.ps1) or [this](https://4sysops.com/archives/create-a-certificate-request-with-powershell) or this.

```powershell
$hostname = "$ComputerName.$domain"
$fileBaseName = $hostname -replace "\.", "_"
$fileBaseName = $fileBaseName -replace "\*", ""

$infFile = $workdir + "\" + $fileBaseName + ".inf"
$requestFile = $workdir + "\" + $fileBaseName + ".req"
$CertFileOut = $workdir + "\" + $fileBaseName + ".cer"
$subject = "CN=$hostname"

Try {
    Write-Verbose "Creating the certificate request information file ..."
    $inf = @"
[Version]
Signature="`$Windows NT`$"

[NewRequest]
Subject = "$subject"
KeySpec = 1
KeyLength = $Keylength
Exportable = TRUE
FriendlyName = "$hostname"
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0
"@

    $inf | Set-Content -Path $infFile

    Write-Verbose "Creating the certificate request ..."
    & certreq.exe -new "$infFile" "$requestFile"

    Write-Verbose "Submitting the certificate request to the certificate authority ..."
    & certreq.exe -submit -config "$CertificateAuthority" -attrib "CertificateTemplate:WebServer" "$requestFile" "$CertFileOut"

    if (Test-Path "$CertFileOut") {
        Write-Verbose "Installing the generated certificate ..."
        & certreq.exe -accept "$CertFileOut"
    }
}
Finally {
    Get-ChildItem "$workdir\$fileBaseName.*" | remove-item
}
```

And then to configure WinRM, you'll grab your certificate's thumbprint and go from there. It might look like this.

```powershell
Write-Host "Obtaining the Thumbprint of the CA Certificate"
$thumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "$hostname" -and $_.EnhancedKeyUsageList[0].FriendlyName -eq "Server Authentication"} ).Thumbprint | Select -first 1

Write-Host "Enable HTTPS in WinRM.."
$ipAddress = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.Ipaddress.length -gt 1} 
$ip = $ipAddress.ipaddress[0]
winrm create winrm/config/Listener?Address=IP:$ip+Transport=HTTPS "@{Hostname=`"$hostname`"; CertificateThumbprint=`"$thumbprint`"}"
winrm set winrm/config '@{MaxTimeoutms="1800000"}'

Write-Host "Re-starting the WinRM Service"
net stop winrm
net start winrm

Write-Host "Open Firewall Ports"
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5986
```

After that custom script extension passes, then you can remote into that machine via HTTPS with a remote_exec provisioner or whatever you need.

<img src='/assets/article_images/2019-04-17-terraform-and-winrm/winrm.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

_Great, so problem solved, right?_
Almost. Your DNS entry may not become available on the DNS servers for a while, making authentication with your DNS name not possible until the entry is set. It's possible that replication from the DNS server to others takes about 15 minutes and from the office to Azure is another 15 minutes. You could try resolving the DNS name of the new VM by running a Powershell command to do a force lookup of the DNS by using your internal DNS servers directly. Those servers should basically give you a result immediately. If that doesn't work, as a last resort, you can simply add some functionality to our remote_exec script that adds the DNS entry to the provisioner's hosts file (and clean it up afteward).

_Why shouldn't I just use Terraform's suggested method for enabling WinRm over HTTPS?_
Tombuildsstuff created an [excellent example](https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples/virtual-machines/provisioners/windows) which creates a new certificate in Key Vault, installs it on the node being provisioned, and configures WinRm during VM provisioning using that certificate to create the HTTPS WinRM listener during VM provisioning. However, again, check your Group Policy to see if it allows WinRm on a certificate that's not issued by your domain. If you can’t request a certificate unless you're on the domain, then you have a little chicken and egg problem.

_Why wouldn't I just use the stock gallery image that has WinRM configured already?_
You can't configure WinRM over HTTPS this way, so it's less secure. It _is_ an option, just not very attractive. It also doesn't follow most people's standards of using images, like the Shared Image Gallery in Azure with Packer-built images.

## Concluding Thoughts

Terraform doesn't want to replace a pipeline tool (Jenkins) or a configuration management tool (Chef), and we shouldn't try to make it. When we try to make tools do things they weren't made to do, we get frustrated pretty quickly. That said, use with caution and use your best judgment.
