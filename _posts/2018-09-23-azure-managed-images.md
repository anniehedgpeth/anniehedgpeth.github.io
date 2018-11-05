---
layout: post
title:  "Packer and Azure Managed Images"
date:   2018-09-23 09:00:00
categories: devops, azure, packer, managed images
tags: devops, azure, packer, managed images
image: /assets/article_images/2018-09-23-managed-images/2018-09-23-managed-images.jpg
image2: /assets/article_images/2018-09-23-managed-images/2018-09-23-managed-images-mobile.jpg
---
I ran across an interesting question at work the other day for which I had to do a little digging, so I thought I'd share it with you to maybe save you some of the digging of your own.

**Disclaimer:** I'm only talking about AZURE here, so if you see me write "subscription" just know I'm talking about an Azure RM subscription. Also, this assumes that all of the subscriptions are under the same AAD [(Azure Active Directory)](https://www.googleadservices.com/pagead/aclk?sa=L&ai=DChcSEwji4t7rvdbdAhWXVw0KHdDkBnkYABAAGgJxYg&ohost=www.google.com&cid=CAESQeD2PH4wHnpZykrCS1AHYXFBpYP7yBGgLS7gu5xsKLi9XOAWHRtj7_3RcCKelJEoFJ6t5nH-o-agHVvInP1yAE4n&sig=AOD64_3D8HbbMxK7ebZZMwHLHDISMcbCXA&q=&ved=2ahUKEwjuntjrvdbdAhUCoVMKHV_7BhsQ0Qx6BAgCEAI&adurl=) group and that you or your [Service Principal](https://docs.microsoft.com/en-us/powershell/azure/create-azure-service-principal-azureps) have access and rights to the necessary subscriptions.

# The Problem and the Goal

We wanted to create managed images at a base level so that the provisioning and configuring is a bit quicker and less error prone since there would be less to do. We'd have just one base image for each type of server, i.e. web, agent, SQL, etc. It was important for us that we didn't have to keep the same image in several different subscriptions. Our end goal was to create a bunch of managed images in Azure using Packer and Chef and use them across several subscriptions and regions, as opposed to having the same image in multiple subscriptions.

We were already doing that, and it wasn't working for us. We had a lot of managed images in several different subscriptions, which is wasteful and error prone. How can you ensure that all of the images are up to date and the same? You may look in your desired subscription, see that the image you want isn't there, and create a new one. But, "Oh wait," you say, "let's just make this one little tweak to the code first," and now your image is different than the standard image. As you can see, this can get out of hand and become very error prone quickly, so wouldn't it be easier to just have one golden image for each of your component servers?

Also, we don't want to have to keep the un-generalized OS disk around for these images. They're just base images so it's not necessary, therefore we don't want to pay for something that's not necessary.

Fear not, dear friends, I learned that we are able to achieve this state, however, I'd like to clear up a few questions we had along the way.

# Questions

## 1. What's the difference between an Azure "Snapshot" and an Azure "Managed Image"?

This is an important distinction because they are not interchangeable and what you can do with one, you can't necessarily do with the other. I don't find the Microsoft documentation to be super clear about this, so when I was researching it, I kept thinking that I would be able to do something, but really I couldn't because I was reading about snapshots and not managed images. I ran across a GitHub discussion where [@Karishma-Tiwari-MSFT](https://github.com/Karishma-Tiwari-MSFT) laid it all out very clearly. [She says](https://github.com/MicrosoftDocs/azure-docs/issues/12540):

> A VM [managed] Image contains an OS disk, which has been generalized and needs to be provisioned during deployment time. OS Images today are generalized. This is meant to be used as a “model” to quickly stamp out similar virtual machines, such as scaling out a front-end to your application in production or spinning up and tearing down similar development and test environments quickly.

> An image of a virtual machine is a copy of the VM which encompasses the full definition of [the] virtual machine’s storage, containing the OS disk, all data disks, data files and applications. It captures the disk properties (such as host caching) you need in order to deploy a VM in a reusable unit.

> A Snapshot contains an OS disk, which is already provisioned. It is similar to a disk today in that it is “ready-to-use”, but unlike a disk, the VHDs of a Snapshot are treated as read-only and copied when deploying a new virtual machine. A snapshot is a copy of the virtual machine's disk file at a given point in time, meant to be used to deploy a VM to a good known point in time, such as check pointing a developer machine, before performing a task which may go wrong and render the virtual machine useless.

I thought she did a great job describing the difference, and Microsoft should use it for their documentation, but I digress.

So if the snapshot isn't generalized, then that means that you can't do certain things that you might want to do with an image, like change the hostname. It's not generic enough like an image is.

What I will be discussing in this post is definitely "Managed Images" not "Snapshots". As a freebie, though, I can tell you that Snapshots seem much easier to move around. The PowerShell module “AzureRmSnapshot” will work for moving snapshots across regions and subscriptions. Likewise, there is a PowerShell module for copying managed disks, as well, but I have yet to find one for managed images without the un-generalized OS disk (more on that later).

## 2. Does Packer allow you to publish Managed Images to multiple subscriptions and regions?

Sort of, but it's not very elegant for Azure.

In your [Packer template](https://github.com/hashicorp/packer/blob/master/examples/azure/windows.json#L12), each region and subscription would need its own builder and unique name for which you need to add a name parameter to this section.

Packer is essentially building a VM, generalizing it, making it into an image, and then deleting everything except for the image. That means that a virtual machine is getting built into _each_ of those subscriptions and regions in order to create an image out of it. That's a bit heavy for my liking.

It'd be great if Azure had the capability of copying managed images from subscription to subscription and region to region, but it doesn't without the un-generalized OS disk. I'm not sure why the capability isn't there for Azure (it is with [AWS](https://www.packer.io/docs/builders/amazon-ebs.html#ami_regions)). Either Packer would need to bake into their code to copy the images over _before_ generalizing the OS disk or Azure would need to create a way to copy managed images without the un-generalized OS disk. Regardless, we're kinda stuck doing it this way for now. (09/23/2018)

## 3. Does Azure allow you to use Managed Images in one subscription to build virtual machines in another subscription?

Quick answer: YES!

This was a little confusing to me as the [docs say](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/build-image-with-packer):
> If you wish to create VMs in a different resource group or region than your Packer image, specify the image ID rather than image name. You can obtain the image ID with Get-AzureRmImage.

That's all well and good, but it says nothing about creating the VM in another subscription.

So I went over to the GitHub documentation for Test Kitchen's `kitchen-azurerm` driver. And lo and behold, in [example 5](https://github.com/test-kitchen/kitchen-azurerm#kitchenyml-example-5---deploy-vm-to-existing-virtual-networksubnet-use-for-expressroutevpn-scenarios-with-private-managed-image) you can see that the driver uses an `image_id` rather than an `image_urn`. I kicked off a Test Kitchen build using an image from another subscription than the one I was provisioning into, and it worked!

Under the hood, the kitchen-azurerm driver is an ARM template, so that simple little test validated for me that it would work to create a VM from an image in another subscription. If you were to use the Azure CLI, ARM template, Terraform, PowerShell, or whatever else to provision your virtual machine from the managed image, you'd simply specify the image ID (which contains the subscription ID) and not the image name.

Here is an example of creating a VM in one subscription using an image in another subscription using [AZ CLI](https://docs.microsoft.com/en-us/cli/azure/ext/image-copy-extension/image?view=azure-cli-latest):

```
$ az vm create --name test-ah123 --resource-group test-ah3 --image /subscriptions/1234-subscription-id-of-image-5678/resourceGroups/image-RG/providers/Microsoft.Compute/images/my-image

# output
{
  "fqdns": "",
  "id": "/subscriptions/9876-subscription-id-to-create-vm-54321/resourceGroups/test-ah3/providers/Microsoft.Compute/virtualMachines/test-ah123",
  "location": "centralus",
  "macAddress": "xx-xx-xx-xx-xx-xx",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "40.123.456.789",
  "resourceGroup": "test-ah3",
  "zones": ""
}
```

This was great news for us because that took away the need to create images in multiple subscriptions.

There is one kicker: you have to make sure to turn on image-sharing permissions to your subscription. In one case, I had a subscription that I wanted to provision a VM into, and the image-sharing permissions were turned off, so I got this Test Kitchen error:

```
Failed to complete #create action: [{"error"=>{"code"=>"BadRequest", "message"=>"Image sharing not supported for subscription."}}] on windows-vm-azure
```

Right now the UserImageSharing feature is only in *PRIVATE PREVIEW*. If you want to use that, you can run this to enable the image sharing:

```POWERSHELL
Register-AzureRmProviderFeature -ProviderNamespace Microsoft.Compute -FeatureName "UserImageSharing"
```

It takes a few minutes, but you can monitor the feature registration with this:

```POWERSHELL
Get-AzureRmProviderFeature -ProviderNamespace Microsoft.Compute -FeatureName "UserImageSharing"
```

(Thanks, for that tip, Robert!)

## 4. But how _do_ you copy Managed Images from one subscription or region to another?

I was still really curious about how you would actually copy the images to other subscriptions just in case we ran across a situation where we couldn't change the image sharing permissions on a subscription or whatever else might come up. I learned that you can use `az image copy` to copy managed images to another region and/or another subscription. However, the thing that makes it super inconvenient is that it relies on the **un-generalized source OS disk** as the actual source of the copy. Therefore, if you want to copy the managed image to other regions or subscriptions, you will have to have the un-generalized OS disk from the original VM.

This is important because I'm pretty sure that Packer doesn't give you the option to copy it somewhere first. It does give you the option to not delete the original VM upon error but not upon a non-erred completion.

The non-Packer automation workflow super sucks, and I'd love to hear from anyone that knows of a better solution. [This guy](https://michaelcollier.wordpress.com/2017/05/03/copy-managed-images/) has a detailed plan lined up, but it would probably look something like:

1. Create (ARM, PowerShell, Azure CLI, whatever) and configure (Chef, Ansible, etc.) a VM in a subscription however you want.
2. Take snapshot to preserve the OS disk
3. [Sysprep/Generalize](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation) the VM
4. Create an Image from the Generalized VM after it is finished deallocating. i.e. `$ az image create -g RG-one -n my-image --source vm-name`
5. Use `az image copy` or the PowerShell equivalent to copy the image from one subscription to another.

See the command below and note that it has a `--target-subscription` parameter in which to put the name or ID of the subscription where the final image should be created.

```
az image copy --source-object-name
              --source-resource-group
              --target-location
              --target-resource-group
              [--cleanup]
              [--parallel-degree]
              [--source-type {image, vm}]
              [--tags]
              [--target-name]
              [--target-subscription]
```

It would look something like:

```
$ az image copy --source-object-name my-image --source-resource-group RG-one --target-location centralus --target-resource-group other-RG --target-subscription 12345-target-sub-67890 # different sub than you're logged in as
```

But gah, doesn't that sound like such a huge pain in the butt and prone to errors all over the place?

All in all, it's better just to use separate builders in the Packer template. Sure it's doing the same thing, but it's simpler to execute and you don't have to have the un-generalized OS disk laying around forever.

# Decision and Concluding Thoughts

In the end, we'd like to never have to do the workflow in #4 because we will hopefully not _need_ to. Because Azure allows you to create a VM from an image in a different subscription and region, it is not likely that we will need to copy images.

<img src='/assets/article_images/2018-09-23-managed-images/mountain-managed-image.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />
^ It's a mountain-scape image...get it??

And as always, if you see any errors in this post, [create a pull request](https://github.com/anniehedgpeth/anniehedgpeth.github.io) with the fix and give yourself credit! Cheers!
