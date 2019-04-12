---
layout: post
title:  "Azure's Managed Identity in Test Kitchen"
date:   2019-04-12 12:00:00
categories: chef, test kitchen, devops, azure, managed service identity, service principal
tags: chef, test kitchen, devops, azure, managed service identity, service principal
image: /assets/article_images/2019-04-12-managed-identities/managed-identities.jpg
image2: /assets/article_images/2019-04-12-managed-identities/managed-identities-mobile.jpg
---
I'm a big fan of Test Kitchen for testing Chef, and I really like the `kitchen-azurerm` driver. I started my client with it two years ago, and they're using it for all of their cookbook CI/CD now. It's fantastic. However, we've had a little nagging problem ever since we started using it: what to do with that darn client secret of the service principal. We had been saving it as an environment variable both on our workstations and on Jenkins, but you can see why that's not desirable - too easy to let it lose out into the wild.

Last fall, Microsoft introduced [Azure Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview). In its documentation, they outline our problem exactly:

>> A common challenge when building cloud applications is how to manage the credentials in your code for authenticating to cloud services. Keeping the credentials secure is an important task. Ideally, the credentials never appear on developer workstations and aren't checked into source control. Azure Key Vault provides a way to securely store credentials, secrets, and other keys, but your code has to authenticate to Key Vault to retrieve them.

To solve this, they created managed identities. Basically, you create a "user-assigned managed identity" in your subscription as a stand-alone resource. From there, Azure assigns that resource an Active Directory identity - kind of like creating a service principal. But then, unlike a service principal that you use _on_ a machine, you assign this identity _to_ a machine, and now that machine _has_ all of the permissions assigned to the managed identity. I love this. I think it's so convenient.

Problem solved, right? Oh, but how can I assign an identity to my test kitchen nodes? Well, you couldn't until recently when [zanecodes](https://github.com/zanecodes) [added its functionality](https://github.com/test-kitchen/kitchen-azurerm/commit/22bc172e415ec07c25f9461d9047513359c61866) to the [kitchen-azurerm](https://github.com/test-kitchen/kitchen-azurerm#kitchenyml-example-10---enabling-managed-service-identities) driver.

Now, all you have to do is create a Test Kitchen identity resource in your subscription with all of the permissions that it needs, nothing less, nothing more. And then add that one little line `user_assigned_identities` to the driver section of the `.kitchen.yml` of your cookbook.

```yaml
driver:
  name: azurerm
  subscription_id: '555-your-sub-id-here-555'
  location: 'Central US'
  machine_size: 'Standard_D2_V2'
  image_urn: MicrosoftWindowsServer:WindowsServer:2016-Datacenter:latest
  user_assigned_identities:
    - /subscriptions/555-your-sub-id-here-555/resourcegroups/test_kitchen_stuff/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test-kitchen-identity
```

And you can remove that dreaded client secret from your environment variables! Yay for security!