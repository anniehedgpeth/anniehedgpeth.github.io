---
layout: post
title:  "Terraform + Azure + Chef + WinRM"
date:   2017-07-30 12:00:00
categories: azure, terraform, chef, winrm, kerberos, ntlm, dns, ca cert
tags: azure, terraform, chef, winrm, kerberos, ntlm, dns, ca cert
image: /assets/article_images/2019-04-11-terraform-and-winrm/terraform-and-winrm.jpg
image2: /assets/article_images/2019-04-11-terraform-and-winrm/terraform-and-winrm-mobile.jpg
---

Walk with me for a moment if you will. I'll tell you of the horrors of trying to bootstrap a Windows node to Chef server in Terraform with WinRM over HTTPS with Kerberos authentication. I hope that this post will prevent some of you from diving into the same rabbit hole in which I found myself. It sucked, and I don't wish it on any of you.

*Acceptance Criteria:*
Bootstrap a node to Chef within Terraform automation

*Scenario:*
Provisioning a Windows 2016 Server with Terraform from a Shared Image Gallery image

*Challenges:*

1. The node being provisioned needed to be on the domain.
2. There was an Active Directory Group Policy requiring that WinRM be authorized via Kerberos
3. Bootstrap Chef as a domain account user

So let's talk about this...

I’m trying to bootstrap Chef in Terraform as a domain account user, but that requires WinRM to be enabled, and we'd prefer that we bootstrap over HTTPS rather than HTTP for more security. The way you do that is by [importing a certificate](https://www.thewindowsclub.com/manage-trusted-root-certificates-windows) and then creating a "winrm listener" that is authenticated by that certificate. All you do for that is add this line to your `winrm config`, and you can add it simply by running this in Powershell:

```
# Get the thumbprint of the certificate first. You may have to add more criteria to narrow it down if there are others w/hostname in the name.
$thumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -match "$hostname").Thumbprint

# Create a listener that uses that thumbprint.
winrm create winrm/config/Listener?Address=IP:$ip+Transport=HTTPS "@{Hostname=`"$hostname`"; CertificateThumbprint=`"$thumbprint`"}"
```

Great, right? Let's get that certificate and get moving.

Oh wait...no random self-signed certificate that I could spin up in Key Vault would do. No, our Group Policy mandated that the certificate be signed by the Certificate Authority (CA) and that the CA be our company, let's call it "Fireside, Inc". So we'll need to request a certificate from Fireside, Inc. But we need to be on the domain to do that...and we can't be on the domain until we add a domain user to the node...and we can't add a domain user to the node

But how in the world do you get WinRm configured if you need to request the certificate from the Certificate Authority (CA) as the domain user?
As long as that domain user is in the Administrator's group on the machine you are provisioning, it should have the required access rights. Of course that means that the machine must be domain joined. But how do you run as that user if your Group Policy doesn't allow you to use an `Invoke-Command` or a `PSSession` as that user unless the user trying to run those commands are _also_ a domain account user? Those require WinRM access, and you don't have that configured yet.

_Why didn't I just do an unattended install of Chef to bootstrap?_
We do a just-in-time grab of the validator pem (because it's constantly rolling) via a Powershell function we created that sets up the user's .chef folder. So, yeah, it would have been great to grab the pem and put it on the node (as that is required for the unattended install), however, there’s no way of getting it onto the node with Terraform via a file or remote_exec provisioner without WinRm already being configured.

_Why didn't you use Terraform's suggested method for enabling WinRm over HTTPS?_
Tombuildsstuff created an [excellent example](https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples/virtual-machines/provisioners/windows) which creates a new certificate in Key Vault, installs it on the node being provisioned, and configures WinRm during VM provisioning using that certificate to create the HTTPS WinRM listener during VM provisioning. However, again, our Group Policy doesn’t allow WinRm on a certificate not issued by our domain. The problem is that I can’t request a certificate unless I’m on the domain, and I can’t do that in Terraform without WinRm via a remote-exec resource.

_Why don't you just use the stock gallery image that has WinRM configured already?_
We can't configure WinRM over HTTPS this way, so it's less secure. It _is_ an option, just not very attractive. It also doesn't follow our standards, as we use the Shared Image Gallery in Azure with Packer-built images.

_How did you configure WinRM with Kerberos authentication in Terraform?_
In an `azurerm_virtual_machine_extension` which runs as the non-domain local admin user we called [Matt Wrock's Powershell script](https://github.com/WinRb/winrm-elevated/blob/master/lib/winrm-elevated/scripts/elevated_shell.ps1) called `elevated_shell.ps1` within a gem he created called `winrm-elevated` in order to call another script that we created called `setupWinRm.ps1` that requests a the certificate from the Certificate Authority (CA) as the domain user. Then we configured WinRM for HTTPS on 5986 with that certificate and opened the firewall for HTTPS. That process enables WinRM for HTTPS through Kerberos authentication.

_Great, so problem solved, right?_
Almost. The theoretical max for a DNS entry to become available on the domain is 30 minutes. Replication from that server to others takes about 15 minutes and from the office to Azure is another 15 minutes. We tried resolving the DNS name of the new VM by running a Powershell command to do a force lookup of the DNS by using our internal DNS servers directly. We ran this command on all 4 DNS server's IP addresses. IT said that using those servers should basically give us a result immediately. For whatever reason, that did not work, so as a last resort, we simply added some functionality to our boostrap script that added the DNS entry to the provisioner's hosts file (and clean it up afteward). And it worked! The bootstrap would then run perfectly as a `local_exec` provisioner within a `null_resource`.

This was the command that worked perfectly after the above WinRM and DNS configuration was finished.

```
knife bootstrap windows winrm me.firesideinc.corp --winrm-user firesideinc.corp\myuser --winrm-password xxxxx-password-xxxxx --node-name me.firesideinc.corp -r my_cookbook::default -E dev_env --bootstrap-version 14.10.9 -y --winrm-authentication-protocol kerberos -p 5986 --winrm-ssl-verify-mode verify_none
```

But the last hitch in the plan was the timeout. You can’t put a timeout on a `null_resource`, so it times out and fails if the bootstrap and chef-client run don't finish within two minutes. Our chef-client run was expected to take an hour.

_What about Terraform's Chef provisioner? Surely it has a longer timeout?_
First, I found that it didn't accept Kerberos authentication, so I looked like it was not an option. Then I found that I could use [NTLM (Negotiate)](https://docs.microsoft.com/en-us/windows/desktop/WinRM/authentication-for-remote-connections#negotiate-authentication) authentication.

The [Chef docs](https://docs.chef.io/knife_windows.html#negotiate-ntlm) say:
>> When knife is executed from a Microsoft Windows system, it is no longer necessary to make additional configuration of the WinRM listener on the target node to enable successful authentication from the workstation. It is sufficient to have a WinRM listener on the remote node configured to use the default configuration for winrm quickconfig. This is because knife windows supports the Microsoft Windows negotiate protocol, including NTLM authentication, which matches the authentication requirements for the default configuration of the WinRM listener.

So I tried it, and it worked! Smooth sailing....almost. I still had the limitation of the null_resource timeout.

_What about the timeout block that you can add to Terraform resources?_

```
  timeouts {
    create = "60m"
    delete = "2h"
  }
```

That timeout block is a teaser. There are only a handful of resources that you can add it to, and null_resource is not one of them.

# 3 options going forward

1. We can bootstrap the node with an empty run_list and create a scheduled task in Windows to kick Chef off later and then exit. What I don't like about this is that you don't know if the node ever converged 

2. We can use a stock gallery image and WinRM over HTTP. I don't super love this option since it's not as secure and we need to use images we build.

3. Technically, we can still _bootstrap_ within this TF automation. I mean, we have a sweet script that requests a CA cert, safe HTTPS WinRM, the whole nine yards. Maybe we just tack a Chef run_list onto the node afterward with Jenkins.

# Concluding Thoughts

Terraform doesn't want to replace a pipeline tool (Jenkins) or a configuration management tool (Chef), and we shouldn't try to make it. When we try to make tools do things they weren't made to do, things get frustrating quick.