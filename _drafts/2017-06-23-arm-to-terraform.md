---
layout: post
title:  "VM from Custom Image with Terraform and Azure"
date:   2017-06-23 09:00:00
categories: provisioning, terraform, azure, cloud, infrastructure as code
tags: provisioning, terraform, azure, cloud, infrastructure as code, arm
image: /assets/article_images/2017-06-23-arm-to-terrafomr/arm-to-terrafomr.jpg
image2: /assets/article_images/2017-06-23-arm-to-terrafomr/arm-to-terrafomr-mobile.jpg
---
So you want to translate your ARM template into a Terraform script. Well, I can help you with that.

First of all, what are the main components of an [ARM template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates)?

```json
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "",
    "parameters": {  },
    "variables": {  },
    "resources": [  ],
    "outputs": {  }
}
```

And in even greater detail...

```json
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "",
    "parameters": {  
        "<parameter-name>" : {
            "type" : "<type-of-parameter-value>",
            "defaultValue": "<default-value-of-parameter>",
            "allowedValues": [ "<array-of-allowed-values>" ],
            "minValue": <minimum-value-for-int>,
            "maxValue": <maximum-value-for-int>,
            "minLength": <minimum-length-for-string-or-array>,
            "maxLength": <maximum-length-for-string-or-array-parameters>,
            "metadata": {
                "description": "<description-of-the parameter>" 
            }
        }
    },
    "variables": {  
        "<variable-name>": "<variable-value>",
        "<variable-name>": { 
            <variable-complex-type-value> 
        }
    },
    "resources": [
      {
          "condition": "<boolean-value-whether-to-deploy>",
          "apiVersion": "<api-version-of-resource>",
          "type": "<resource-provider-namespace/resource-type-name>",
          "name": "<name-of-the-resource>",
          "location": "<location-of-resource>",
          "tags": {
              "<tag-name1>": "<tag-value1>",
              "<tag-name2>": "<tag-value2>"
          },
          "comments": "<your-reference-notes>",
          "copy": {
              "name": "<name-of-copy-loop>",
              "count": "<number-of-iterations>",
              "mode": "<serial-or-parallel>",
              "batchSize": "<number-to-deploy-serially>"
          },
          "dependsOn": [
              "<array-of-related-resource-names>"
          ],
          "properties": {
              "<settings-for-the-resource>",
              "copy": [
                  {
                      "name": ,
                      "count": ,
                      "input": {}
                  }
              ]
          },
          "resources": [
              "<array-of-child-resources>"
          ]
      }
    ],
    "outputs": {
        "<outputName>" : {
            "type" : "<type-of-output-value>",
            "value": "<output-value-expression>"
        }
    }
}
```

Advantages over ARM:
 - Readability (HCL vs. JSON)
 - Plan (allows us to see what will change before it changes)
 - Extensibility (can extend with any command you can run locally or remotely)
 - Modularity (modules can be depended on/reused across templates)
 - Syntax (clearer syntax, more powerful string interpolation, can use templated scripts to extend VM config)
 - Extends beyond just Azure resources

Disadvantages:
 - Requires users to learn Terraform vs. native Azure tooling
 - Component support can lag behind ARM


When to break up:

Modules (any reproducible chunk of code that produces a single thing, i.e. a hub/spoke network, bastion host, VPN gateway, Chef server, etc.)

Stack (any unique resources or combination of modules that you want separated by tfstate - should be distinct and able to be destroyed/rebuilt separately, ideally)

Environment (like a stack, but the only difference is variable inputs - creates a separate tfstate per environment based on the same stack)