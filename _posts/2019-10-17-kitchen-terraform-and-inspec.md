---
layout: redirect
title:  "Terraform + Kitchen + InSpec"
date:   2019-10-17 12:00:00
categories: azure, terraform, ssh, test kitchen, kitchen terraform, winrm, terratest
tags: azure, terraform, ssh, test kitchen, kitchen terraform, winrm, terratest
image: /assets/article_images/2019-10-17-kitchen-terraform/kitchen-terraform.jpg
image2: /assets/article_images/2019-10-17-kitchen-terraform/kitchen-terraform-mobile.jpg
redirect: https://hedge-ops.com/kitchen-terraform
---
**Disclaimer:** I like for my blog posts to be pretty basic so that you can pick up a new skill without knowing a ton of background, but this post assumes that you know about [InSpec](http://www.anniehedgie.com/inspec-basics-11), [Terraform](http://www.anniehedgie.com/terraform-and-azure), and [Test Kitchen](http://www.anniehedgie.com/red-green-refactor). It also assumes that you know how to [call a Terraform module from another module](https://www.terraform.io/docs/configuration/modules.html) and that you have knowledge of the [kitchen-terraform](https://github.com/newcontext-oss/kitchen-terraform) gem.

1. [So what's the problem](#so-whats-the-problem)
1. [How to do it in Test Kitchen](#how-to-do-it-in-test-kitchen)
1. [Testing, though](#testing-though)
1. [Concluding Thoughts](#concluding-thoughts)

## So what's the problem

I want to test my Terraform deployments while I'm in the process of development.

I had long been frustrated with a Terraform development testing strategy that leveraged InSpec and that I thought would be worthwhile. I have always seen the value in running an InSpec profile after a Terraform deployment to test, so I had started doing that, like I [showed you here](http://www.anniehedgie.com/inspec-basics-11). I had heard about [Test Kitchen for Terraform](https://github.com/newcontext-oss/kitchen-terraform) (the `kitchen-terraform` gem) and wanted to use it, but I found it cludgy and thought that the test module was too abstracted from the actual Terraform module you're developing. Plus, I didn't find that it gave me anything new from simply running an InSpec profile after a Terraform run.

## InSpec as a null_resource / local_exec

I started trying to develop Terraform modules using that testing strategy above, and I found it to be slow and cumbersome. Running InSpec after Terraform is nice for validation of provisioning, but when you have to run your entire `terraform apply` before seeing your InSpec output while you're currently developing your module and tests is not fun.

What you would do is what I outlined in this [post](http://www.anniehedgie.com/inspec-basics-11). And if you're wanting to validate both resource provisioning as well as vm configuration, then you'd use a [null_resource](https://www.terraform.io/docs/providers/null/resource.html) with multiple InSpec commands in a [local_exec](https://www.terraform.io/docs/provisioners/local-exec.html) command. It would look something like:

```go

resource "null_resource" "inspec" {
    provisioner "local-exec" {
        command = <<EOT
          inspec exec https://github.com/anniehedgpeth/inspec-azure-demo.git -t azure://${var.subscription_id}
          inspec exec https://github.com/anniehedgpeth/demo_profile -t ssh://user@ipaddress
        EOT
    }
    depends_on = [
      your.last.resource.provisioned
    ]
}
```

It works, but the development workflow is slow and cumbersome.

## How to do it in Test Kitchen

I was on a project in which we were using `kitchen-terraform`, and in the beginning I honestly didn't like it. The abstraction, as mentioned above, was confusing to me. And when it came to tests, I couldn't figure out how to test both the resources and the vm configuration.

What you do is create a Test Kitchen module that calls your real module, but you give it all new variable names and can provide dummy dependent resources for it. Therefore, if you implement it wisely, then you can replicate a real module pretty solidly, but it takes a little practice. A great feature of this is that you can add ssh or WinRm on your test node in your _test module only_ when you wouldn't do that in your real module, so it makes testing easier - just jump on the box whenever you need to.

I actually started to like `kitchen converge` which basically performs `terraform plan` and `terraform apply` because it was less of a risk of accidentally blowing away any necessary resources. Ironically, the thing I liked most about it was that it _was abstracted_ from the actual module that I was developing.

### Testing, though

It's obvious that you'll be provisioning several resources in Azure (or your cloud of choice), and if you're provisioning any virtual machine, you'll probably be putting at least a little configuration on that node, whether it be a full-blown [Chef](https://docs.chef.io/) run or a little something with [cloud-init](https://cloudinit.readthedocs.io/en/latest/) or whatever.

Because of the need for running InSpec against Azure _and_ a node, I thought that I couldn't use the `kitchen verify` command of `kitchen-terraform` because it has the limitation of only using one InSpec profile, so I could only test either the Azure subscription _OR_ the vm configuration. I was thinking in terms of running an entire profile (not just individual controls) on a [target](https://www.inspec.io/docs/reference/cli/). The good news, though, is that I was wrong!

That means you can have an InSpec profile that has some controls for a vm and some for a subscription, and you'd tell your `.inspec.yml` that this profile supports both, like this:

```yaml
---
name: example-test
title: Example Profile
version: 0.1.0
depends:
  - inspec-azure:
    git: https://github.com/inspec/inspec-azure.git
supports:
  - platform: azure
  - os-family: linux
```

Still, though, you need to run these separately, so how do you do that in the `kitchen-terraform` `.kitchen.yml`? Now, I don't mean to blame the documentation, but I'm just sayin' that the documentation on the GitHub page was not as useful for me as the [RubyDoc documentation](https://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen), which has way more configuration attributes that you may need. I learned there that you can have two different `systems` in your `.kitchen.yml`, which could look like this:

```yaml
driver:
  name: terraform
  root_module_directory: test/fixtures/example-test
  command_timeout: 1200

provisioner:
  name: terraform

verifier:
  name: terraform
  systems:
    - name: vm # this session will target the node config
      backend: ssh
      port: 22
      hosts_output: vm_private_ip # output from test module
      user: exampletestadmin # output from test module
      sudo: true
      key_files:
        - test/fixtures/example-test/.ssh/example_key # created in the test module
      controls:
        - example-vm # this looks for that list of control names in the profile in test/integration/<suite-name>
    - name: azure # this session will target the Azure subscription
      backend: azure
      controls:
        - example-azure-resources # this looks for that list of control names in the profile in test/integration/<suite-name>

platforms:
  - name: terraform

suites:
  - name: example-test
```

When you run `kitchen verify` it will run two separate InSpec sessions for each name in `systems`. I _love_ this.

## Concluding Thoughts

This is a really cool tool, although, I've heard that [Terratest](https://github.com/gruntwork-io/terratest) is the preferred testing strategy of Terraform and Azure. And if you Google "terratest vs inspec" you'll see some of the arguments. But here's my two cents - if you're not testing at all because the barrier to entry for Terratest is too high and you already know kitchen and InSpec because of Chef cookbook development, then by all means, just use InSpec. If it starts not working for you anymore, then sure, go use POC Terratest to see if it's worth learning. My team, however, procrastinated because we wanted to make sure we were implementing the best testing strategy, and `perfect` got in the way of `good enough`. I honestly don't know which is _better_ because I haven't used Terratest, but I do know that my life just got a LOT easier for having implemented Test Kitchen and InSpec in my Terraform development.
