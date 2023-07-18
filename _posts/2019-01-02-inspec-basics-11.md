---
layout: redirect
title:  "InSpec Basics: Day 11 - Validating Azure Resources with InSpec Azure"
date:   2019-01-02 12:00:00
categories: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, azure, inspec-azure, terraform
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, azure, inspec-azure, terraform
image: /assets/article_images/2019-01-02-inspec-basics-11/inspec-basics-11.jpg
image2: /assets/article_images/2019-01-02-inspec-basics-11/inspec-basics-11-mobile.jpg
redirect: https://hedge-ops.com/inspec-basics-11
---
Up until InSpec 2.0, you could only use InSpec to scan actual infrastructure. When resources became available in InSpec to scan cloud subscriptions, I was thrilled. There are a million and one reasons you'd want to take stock of your Azure resources. Whether you're trying to validate that your ARM template or Terraform script did what it said it was going to do, or you have compliance standards that you have to audit, or you just want to make sure that you don't write over anything before a deployment, the [`inspec-azure`](https://github.com/inspec/inspec-azure) resource pack is a great tool for this.

But first, if you've missed out on any of my tutorials, you can find them here:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - Day 6: [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
  - Day 7: [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)
  - Day 8: [Regular Expressions](http://www.anniehedgie.com/inspec-basics-8)
  - Day 9: [Attributes](http://www.anniehedgie.com/inspec-basics-9)
  - Day 10: [Attributes with Environment Variables](http://www.anniehedgie.com/inspec-basics-10)

# Why and How

If you like to skip ahead, feel free:

1. [What you are going to do with InSpec in this tutorial](#what-you-are-going-to-do-with-inspec-in-this-tutorial)
1. [Why do I need to validate my Azure subscriptions?](#why-do-i-need-to-validate-my-azure-subscriptions)
1. [Prerequisites](#prerequisites)
1. [InSpec Azure Resource Pack](#inspec-azure-resouce-pack)
1. [RED - write a failing test](#red-write-a-failing-test)
1. [GREEN - make the tests pass with Terraform](#green-make-the-tests-pass-with-terraform)
1. [Concluding Thoughts](#concluding-thoughts)

# What you are going to do with InSpec in this tutorial

1. You will run InSpec both locally and from git to test your Azure subscription in an effort to validate that it is in the state in which it is expected to be in as defined by the InSpec profile.
1. You will use Terraform to create the missing resources and validate their provisioning with your InSpec profile.

# Why do I need to validate my Azure subscriptions

How many times have you run `terraform plan` and then `terraform apply` fails right after that for whatever reason. `terraform plan` is fine for development when you need a quick confirmation of what's already deployed, but what if someone coded something incorrectly, maybe changing an important network security group? Is anyone auditing the subscription that closely? Before you run a `terraform apply`, what if you had an InSpec profile you could run against your Azure subscription to validate the state of your resources? What if you could define the desired state of your subscription an InSpec profile and validate it without actually changing anything? And what if you could validate this whenever you want to ensure that the resources haven't changed? That's really cool, don't you think?

Have you ever used Chef's [`why-run`](https://blog.chef.io/2018/03/14/why-why-run-mode-is-considered-harmful/)? Basically, it's a command that you can run that tells you which Chef resources would change or converge based on your changes and the current state of the node without actually running anything. Sure, you might run it during development to see what happens, but would you ever use this for your compliance audits? Of course not; that's dumb. In the same vein, you'd never simply use `terraform plan` to audit what's in your Azure subscription.

Another scenario - what if you have certain config that you want in all of your Azure subscriptions? How are you validating that? Let's use the network security group example again. What if all of your subscriptions required the same rules? Wouldn't it be nice to just run the same InSpec profile against all of them with one fell swoop?

Okay, if you're convinced that this is a worthwhile pursuit, then read ahead.

# Prerequisites

Now, before we start, let's get some stuff in order. You're going to need the following:

- InSpec is [installed](https://www.inspec.io/downloads/)
- an Azure service principal with contributor rights to your Azure subscription
- a `.azure/credentials` file in your home directory (see ["Azure Platform Support in InSpec"](https://www.inspec.io/docs/reference/platforms/))
- Terraform is [installed](https://www.terraform.io/downloads.html)

If you haven't worked with an Azure service principal before, go to the link above and follow the direction for *Setting up Azure credentials for InSpec* and *Setting up the Azure Credenitals File* exactly. It can be pretty frustrating if you set it up incorrectly, so follow the directions carefully. When you think you're finished, validate that your service principal is set up properly by trying to make a few calls to your Azure subscription with Azure CLI or Powershell. Both instructions will tell you how to log in on the command line with your service principal. If you want to further validate that your service principal can see your resources, then look up some commands such as [`az vm list`](https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-list) or [`Get-AzureRM`](https://docs.microsoft.com/en-us/powershell/module/azurerm.compute/get-azurermvm?view=azurermps-6.13.0) and try them out. Just be careful if you're not familiar with interacting with your Azure subscription from the command line; don't go deleting stuff you're not supposed to be deleting.

# Inspec Azure Resource Pack

So honestly, if you just set up your credentials, then the hard part is over. If you've used InSpec before, then you're smooth sailing from here. If not, then follow along.

The first thing we need to do is create an InSpec profile, so if you remember how to create one, then do that and make sure it's commited to git. If you don't remember, then follow this [quick tutorial](http://www.anniehedgie.com/inspec-basics-5) to set one up.

In order to validate Azure resources, we're now going to put the inspec-azure resource pack to use so that we can run our automated tests against Azure. To do that, all we have to do is tell the InSpec profile to depend on the `inspec-azure` resource pack. To do that, all we need to do is add a few lines to the `inspec.yml` file in your profile. 

Open up the InSpec profile that you just created in your editor of choice (mine's Visual Studio Code), and add these lines to the end of your `inspec.yml`:

```yaml
depends:
  - name: inspec-azure
    url: https://github.com/inspec/inspec-azure/archive/master.tar.gz
supports:
  platform: azure
```

Remember that yaml is white-space sensitive, so use spaces and not tabs.

# RED (write a failing test)

In the spirit of [red, green, refactor](http://www.anniehedgie.com/red-green-refactor), we're going to write a test, watch it fail, remediate, and then watch it pass.

In your controls directory, create a file called `example.rb`. In that file, let's add some tests.

Before that, however, let's create a variable so that we don't have to repeat ourselves. Add this to the top:

```ruby
resource_group = 'my-resources'
```

Now we're going to add our controls. Here are three different tests, now see if you can tell what they're testing:

```ruby
control 'azurerm_virtual_machine' do
  describe azurerm_virtual_machine(resource_group: resource_group, name: 'my-vm') do
    it                                { should exist }
    its('type')                       { should eq 'Microsoft.Compute/virtualMachines' }
  end
end

control 'azure_network_security_group' do
  describe azure_network_security_group(resource_group: resource_group, name: 'nsg') do
    it                            { should exist }
    its('type')                   { should eq 'Microsoft.Network/networkSecurityGroups' }
    its('security_rules')         { should_not be_empty }
    its('default_security_rules') { should_not be_empty }
    it                            { should_not allow_rdp_from_internet }
    it                            { should_not allow_ssh_from_internet }
  end
end

control 'azure_virtual_network' do
  describe azurerm_virtual_network(resource_group: resource_group, name: 'my-network') do
    it               { should exist }
    its('location')  { should eq 'centralus' }
  end
end
```

`control 'azurerm_virtual_machine'`
This control is simply checking that the virtual machine (vm) exists and that its type is "Microsoft.Compute/virtualMachines". It's also expected to be in the resource group that we defined as "my-resources" and the vm name should be "my-vm".

`control 'azure_network_security_group'`
This control is also checking the resource group called "my-resources" for a network security group called "nsg". The actual tests are pretty clear. It should exist. Its type should be "Microsoft.Network/networkSecurityGroups". It should have rules in addition to the default rules. Additionally, it should have a rule that allows remote desktop (RDP) and SSH.

`control 'azure_virtual_network'`
And finally, in that same resource group called "my-resources", there should exist a virtual network called "my-network", and it should exist in the "centralus" region.

# RED (write a failing test)

There are two different ways we're going to run this profile against your subscription. First, we're just going to run it locally, and second, we're going to run it against your profile in git, but that will come later after we've created some resources in Azure to test against.

It's helpful to run locally when you're developing your profile so that you don't have a bazillion git commits of incorrect tests, so let's do that now before you commit your work.

NOTE: This is not making any changes to your subscription.

From the command line of your choice, run this command from the InSpec profile directory on which you're working.

```
$ inspec exec . -t azure://[your-azure-subscription-id-here]
```

If you break that command down, it just means that you're executing the InSpec profile (inspec exec) at the current directory (.), and you're targeting (-t) your Azure subscription.

This InSpec run should fail, but it _should_ be able to connect to Azure. Your failure should look similar to this:

```
Profile: InSpec Azure Demo (inspec-azure-demo)
Version: 0.1.0
Target:  azure://[hidden]

  ×  azurerm_virtual_machine: '' Virtual Machine (5 failed)
     ×  '' Virtual Machine should exist
     expected '' Virtual Machine to exist
     ×  '' Virtual Machine should have monitoring agent installed
     undefined method `osProfile' for nil:NilClass
     ✔  '' Virtual Machine should not have endpoint protection installed []
     ✔  '' Virtual Machine should have only approved extensions ["MicrosoftMonitoringAgent"]
     ×  '' Virtual Machine type should eq "Microsoft.Compute/virtualMachines"

     expected: "Microsoft.Compute/virtualMachines"
          got: nil

     (compared using ==)

     ×  '' Virtual Machine installed_extensions_types should include "MicrosoftMonitoringAgent"
     expected [] to include "MicrosoftMonitoringAgent"
     ×  '' Virtual Machine installed_extensions_names should include "LogAnalytics"
     expected [] to include "LogAnalytics"
  ×  azure_network_security_group: '' Network Security Group (6 failed)
     ×  '' Network Security Group should exist
     expected '' Network Security Group to exist
     ×  '' Network Security Group should not allow rdp from internet
     undefined method `[]' for nil:NilClass
     ×  '' Network Security Group should not allow ssh from internet
     undefined method `[]' for nil:NilClass
     ×  '' Network Security Group type should eq "Microsoft.Network/networkSecurityGroups"

     expected: "Microsoft.Network/networkSecurityGroups"
          got: nil

     (compared using ==)

     ×  '' Network Security Group security_rules
     undefined method `[]' for nil:NilClass
     ×  '' Network Security Group default_security_rules
     undefined method `[]' for nil:NilClass


Profile: Azure Resource Pack (inspec-azure)
Version: 1.2.0
Target:  azure://[hidden]

     No tests executed.

Profile Summary: 0 successful controls, 2 control failures, 0 controls skipped
Test Summary: 2 successful, 11 failures, 0 skipped
```

If it doesn't, then you'll need to try some troubleshooting. You can start with the following:

- your InSpec installation (run `inspec -v` to make sure you have a version)
- your inspec.yml file (check against [this](https://github.com/anniehedgpeth/inspec-azure-demo/blob/master/inspec.yml))
- your `.azure/credentials` file ([this](https://github.com/test-kitchen/kitchen-azurerm#configuration) is a good resource)
- your service principal being logged into Azure from the command line properly ([PowerShell](https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-1.0.0#sign-in-with-a-service-principal) or [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest#sign-in-using-the-service-principal))
- are you in the right directory :)

If you did successfully run your InSpec profile against your Azure subscription and get the expected failures as noted above, then GREAT! Now *commit that bad boy to git*, and let's move on to the next step! Let's remediate those failures by adding some resources to your subscription so that those tests pass.

# GREEN (make the tests pass with Terraform)

To make this easier, we're going to use Terraform to create the resources InSpec expects to see in this Azure subscription. If you want to do this without Terraform, say manually in the portal, with PowerShell, Azure CLI or whatever, feel free! But IMHO, this is the easiest way to remediate our failures. Onward!

First, make sure Terraform is installed by running `terraform -v`.

Good? Good (I hope).

Now, let's create another directory outside of your InSpec profile (doesn't matter where, just _not in_ your profile). Call it `inspec-azure-terraform-demo`. You can either clone [this repo](https://github.com/anniehedgpeth/inspec-azure-terraform-demo.git) that I already pre-baked for you, or just copy [this file](https://github.com/anniehedgpeth/inspec-azure-terraform-demo/blob/master/vm.tf) and paste it into a file called `vm.tf`, and open that in your editor of choice (mine's Visual Studio Code).

If you're looking carefully, I snuck in a resource at the very end of this file that will run InSpec for us! Pretty cool, right? It looks like:

```
resource "null_resource" "inspec" {
    provisioner "local-exec" {
        command = "inspec exec https://github.com/anniehedgpeth/inspec-azure-demo.git -t azure://${var.subscription_id}"
    }
}
```

What you'll need to do, though, is *change that git url to point to your repo*.

Remember before when we just used the path `.` to point to our profile? Well, now we're going to use your git url as the path to point to the profile. You can run this now to execute InSpec against your profile stored in git, just to see that it works. Remember to replace the necessary values.

```
$ inspec exec https://github.com/[your-git-here]/inspec-azure-demo.git -t azure://[your-azure-subscription-id-here]
```

You do need one more thing that is not in this repo, and that's a variables file. This Terraform file uses several variables that you don't want to commit to source control (so add it to your `.gitignore` file if you commit this), so create a file called `terraform.tfvars` that looks like this filled in with your Azure service principal (spn) info:

```
subscription_id = "REPLACE-WITH-YOUR-SUBSCIPRTION-ID"
client_id = "REPLACE-WITH-YOUR-SPN-CLIENT-ID"
client_secret = "REPLACE-WITH-YOUR-SPN-CLIENT-SECRET"
tenant_id = "REPLACE-WITH-YOUR-SPN-TENANT-ID"
```

From the command line of your choice, run these commands from this directory:

```
$ terraform plan
```

When you run this command, Terraform is comparing what is in the tfstate file, .tf files, and the Azure subscription to see what needs to be created or changed. If this succeeds, then you can run this to provision the resources:

NOTE: This is creating resources in your Azure subscription.

```
$ terraform apply
```

HOPEFULLY, your output will look like the following - all passing tests now:

```
Profile: InSpec Azure Demo (inspec-azure-demo)
Version: 0.1.0
Target:  azure://[hidden]

  ✔  azurerm_virtual_machine: 'my-vm' Virtual Machine
     ✔  'my-vm' Virtual Machine should exist
     ✔  'my-vm' Virtual Machine type should eq "Microsoft.Compute/virtualMachines"
  ✔  azure_network_security_group: 'nsg' Network Security Group
     ✔  'nsg' Network Security Group should exist
     ✔  'nsg' Network Security Group should not allow rdp from internet
     ✔  'nsg' Network Security Group should not allow ssh from internet
     ✔  'nsg' Network Security Group type should eq "Microsoft.Network/networkSecurityGroups"
     ✔  'nsg' Network Security Group security_rules should not be empty
     ✔  'nsg' Network Security Group default_security_rules should not be empty
  ✔  azure_virtual_network: 'my-network' Virtual Network
     ✔  'my-network' Virtual Network should exist
     ✔  'my-network' Virtual Network location should eq "centralus"


Profile: Azure Resource Pack (inspec-azure)
Version: 1.2.0
Target:  azure://[hidden]

     No tests executed.

Profile Summary: 3 successful controls, 0 control failures, 0 controls skipped
Test Summary: 10 successful, 0 failures, 0 skipped
```

After you are finished, don't forget to destroy the resources you just created with:

```
$ terraform destroy
```

# Concluding Thoughts

There are a ton of resources ready to use that you can find [here](https://www.inspec.io/docs/reference/resources/#azure-resources). I encourage you to take a look and explore what all can be audited with InSpec out of the box.

This is not a new tool, by any stretch. I remember at ChefConf 2017 talking to [Dominik Richter](https://twitter.com/arlimus?lang=en), co-creator of InSpec, about it, and I had to keep it hush because it wasn't released yet. I was very eager to use it because I was working with Terraform a lot at the time, and I could see a ton of value in it. After InSpec 2.0 was released with Azure resources, I gave it a go, but it was buggy for a little while _or maybe I was buggy_, so I didn't use it. Whatever the case, I overcame the user error and the bugs got fixed, and it's super easy now! Like so easy I want to use it for everything.

*Who's has need of validating Azure resources in your organization?* Help them out and whip up a quick profile! Or just send them this post and show them how easy it is to use. Seriously, they'll love you for it.
