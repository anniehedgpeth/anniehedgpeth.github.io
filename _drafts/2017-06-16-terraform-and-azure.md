---
layout: post
title:  "Terraform and Azure"
date:   2017-06-16 12:00:00
categories: provisioning, terraform, azure, cloud, infrastructure as code
tags: provisioning, terraform, azure, cloud, infrastructure as code
image: /assets/article_images/2017-06-16-terraform-and-azure/terraform-and-azure.jpg
image2: /assets/article_images/2017-06-16-terraform-and-azure/terraform-and-azure-mobile.jpg
---
I've been really getting into [Terraform](https://www.terraform.io) lately and have been interested to see how well it plays with [Azure](https://www.terraform.io/docs/providers/azurerm/). I have to say, I'm pretty impressed. In fact, I've had a lot of fun with it. 

If you're not familiar with Terraform, in their words:

> Terraform enables you to safely and predictably create, change, and improve production infrastructure. It is an open source tool that codifies APIs into declarative configuration files that can be shared amongst team members, treated as code, edited, reviewed, and versioned.

First of all, did you know that Azure has a ton of example templates in [Terraform's Github repo](https://github.com/hashicorp/terraform/tree/master/examples)? This is a great starting point if you've never used Terraform before. The templates range in complexity, from a simple Linux virtual machine all the way up to creating an entire OpenShift Origin deployment. You could play around with the deployment of those templates into your Azure account and get pretty familiar with it.

I do have a few tips if you're just getting started with Terraform and Azure:

### 1) Naming Conventions
It super sucks when you're waiting on a really long build only for it to return with an error that your container name can't have an underscore in it. That will only happen once before you find this page on [Azure Naming Conventions](https://docs.microsoft.com/en-us/azure/architecture/best-practices/naming-conventions). You're welcome. Also, be aware of password restrictions! Certain resources require more complex passwords, so be aware that a weak password could fail your build.

### 2) Nesting Resources
Sometimes you can nest resources, such as the subnet within the vnet resource block, like this:

```
resource "azurerm_virtual_network" "test" {
  name                = "virtualNetwork1"
  resource_group_name = "${azurerm_resource_group.test.name}"
  address_space       = ["10.0.0.0/16"]
  location            = "West US"
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }
}
```

This is nice and you feel like you're cheating, but there are a lot of times that you have to reference the subnet ID elsewhere, like here in the NIC's IP config, and you can't do that if it's nested, so you'll have to have two separate blocks, one for VNET and one for subnet.

```
resource "azurerm_network_interface" "nic" {
  name                = "nic${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = 2

  ip_configuration {
    name                                    = "ipconfig${count.index}"
    subnet_id                               = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
    load_balancer_inbound_nat_rules_ids     = ["${element(azurerm_lb_nat_rule.tcp.*.id, count.index)}"]
  }
}
```

### 3) Graphs
I'm a fan of the graphs. I think they can be helpful and even point out errors in the logic of your architecture. If you would like to create a graph of the template that you created, you may run this command from within your template's directory:

```
terraform graph | dot -Tpng > graph.png
```

And you'll end up with something like this inside that directory. Kinda fun, right?

![terraform graph](https://github.com/hashicorp/terraform/blob/master/examples/azure-vnet-two-subnets/graph.png?raw=true)

### 4) [Virtual Machine Extensions](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html)
So I've always heard (and agree with) the sentiment that you should only use Terraform for provisioning infrastructure and leave the configuration of all of those things to the tools that are good at doing configuration (i.e. Chef or Ansible). And I have tried to run many a shell script with Terraform to know that it's a big pain. There are just countless things that can go wrong and waste a whole bunch of your time troubleshooting them (mostly access issues, IMHO).

So normally you would use one of the [provisioners](https://www.terraform.io/docs/provisioners/index.html) such as `remote-exec`, `local-exec`, or `connection` using a `bastion_host`. And sometimes this works wonderfully, and other times you run into a miriad of issues concerning privileges or ssh or something. 

But if access issues cause the majority of those issues, giving Terraform a bad reputation for configuring infrastructure, then what if I told you that there's something that makes configuring Azure infrastructure with Terraform easier? I give you [Virtual Machine Extensions](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/extensions-features). In Microsoft's words:

> Azure virtual machine extensions are small applications that provide post-deployment configuration and automation tasks on Azure virtual machines. For example, if a virtual machine requires software installation, anti-virus protection, or Docker configuration, a VM extension can be used to complete these tasks. Azure VM extensions can be run by using the Azure CLI, PowerShell, Azure Resource Manager templates, and the Azure portal. Extensions can be bundled with a new virtual machine deployment or run against any existing system.

They left [Terraform](https://www.terraform.io/docs/providers/azurerm/r/virtual_machine_extension.html) off of that list, but I'm here to tell you that you can use it with Terraform, too! That means that with this resource:

```
resource "azurerm_virtual_machine_extension" "test" {
  name                 = "hostname"
  location             = "West US"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_machine_name = "${azurerm_virtual_machine.test.name}"
  publisher            = "Microsoft.OSTCExtensions"
  type                 = "CustomScriptForLinux"
  type_handler_version = "1.2"

  settings = <<SETTINGS
    {
        "commandToExecute": "hostname"
    }
SETTINGS
}
```

...Azure will give you a completely open door into that machine for you while you're provisioning with no need to alter its network security group (i.e. ssh rules) or worry about root access or any of that. I love this feature. It really simplifies things. (Here's an example of setting up a [Wordpress MySql Replication](https://github.com/hashicorp/terraform/blob/master/examples/azure-wordpress-mysql-replication/main.tf#L221).)

### 5) [ARM Template Deployment](https://www.terraform.io/docs/providers/azurerm/r/template_deployment.html)
Now hear me out! You're used to the argument being Terraform or ARM, am I right? And the staunch ARM supporters tote that Azure's API will always be better than Terraform's, so if there's a resource that they need, they don't want to wait around for Terraform to create it, yada yada. I get it.

But what if I told you that you could run an ARM template straight FROM Terraform? Think of the leverage that would bring you! There are a LOT of ARM templates out there that you can leverage, and wouldn't it be nice if you could just drop it straight into your Terraform script (like this [example](https://github.com/hashicorp/terraform/blob/master/examples/azure-encrypt-running-linux-vm/main.tf#L77)) using all of your variables? Bam! Instant access to ARM.

# Concluding Thoughts
I still agree with the sentiment that Terraform should do what it does best (standing up infrastructure) and that you should use the correct tool for the job, and that Terraform isn't the correct tool for configuration. In a lot of situations, though, letting Azure do the heavy lifting is a very valid option (re: extensions and ARM deployment).

I've recently seen the news that Hashicorp has decided to split up each of their providers into individually distributed provider plugins because of the explosive growth of providers. That means that instead of shipping all of the providers as part of the main Terraform binary, each provider will have its own plugin and therefore its own Github repo, like this one for [AzureRM](https://github.com/terraform-providers/terraform-provider-azurerm). I think this is great news because it means faster turnaround with bug fixes, features, etc. So stay tuned in to Hashicorp for news of the release of Terraform 0.10. I think it will mean even better things for Azure and Terraform's synergy. 
