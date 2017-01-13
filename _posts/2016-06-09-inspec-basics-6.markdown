---
layout: post
title:  "InSpec Basics: Day 6 - Ways to Run It and Places to Store It"
date:   2016-06-10 03:00:00
categories: chef, chef compliance, inspec, security, inspec tutorial, profile, kitchen, cookbook
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, profile, kitchen, cookbook
image: /assets/article_images/2016-06-09-inspec-basics-6/inspec-basics-6.jpg
image2: /assets/article_images/2016-06-09-inspec-basics-6/inspec-basics-6-mobile.jpg
---
Hello my friends. I hope you're back for some [InSpec](https://github.com/chef/inspec) goodness. I've missed [talking about InSpec](http://www.anniehedgie.com/inspec-basics-1)! Check out all we've covered so far:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)

I've been quite occupied lately building my skill-set with some studying up on Linux, Chef, Kitchen, remediation workflow, and little bit of Ruby so that I can use InSpec in a broader sense. No big. Seriously, though, starting from scratch is not easy, but it's definitely not boring, either. 

I'm not exactly giving you another tutorial today, but instead I want to step back a little bit to get a broader perspective of InSpec. I'm going to talk about the different ways in which we can run InSpec and the different places in which to store it. 

![](/assets/article_images/2016-06-09-inspec-basics-6/whereandhow.png)

## Running and Storing InSpec Locally
Of course we start locally, right? We've [done this already](http://www.anniehedgie.com/inspec-basics-1). You're simply saving the commands to a directory on your local machine and then running them from the command line.

This is obviously just for testing in development. In [film terms](http://www.anniehedgie.com/introduction), I think of this as pre-production, but I guess I need to get used to calling it by its proper name. This is for when we're in the process of [creating our profile](http://www.anniehedgie.com/inspec-basics-5) and seeing if it works. And while we're doing that, we're also [testing like mad](http://www.anniehedgie.com/red-green-refactor) to insure speedy success and to keep things nice and neat.

## Running InSpec Profiles Through Test Kitchen 
I had a lot of fun learning how to do this this week (which is why I was studying up a lot). This is only for testing in development, too. When we run our profiles in Kitchen, we can test against cookbook development and remediate failures through the cookbook.

We can use profiles stored just about anywhere for this: 

  - locally
  - [Github](https://github.com/)
  - [Chef Supermarket](https://supermarket.chef.io)
  - [Chef Compliance](http://www.anniehedgie.com/tour-of-chef-compliance) (you'll need to log in first and use an API token)
  
  Your .kitchen.yml might look a little something like this (pick your `inspec-tests` verifier, of course):

```yaml
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

verifier: 
  name: inspec

platforms:
  - name: centos-6.7

suites:
  - name: default
    run_list:
      - recipe[inspec-workshop-cookbook::default]
    verifier:
      inspec_tests:
        - /Path/to/local/folder
        - https://github.com/<username>/<profilename>
        - supermarket://<owner>/<profile-name>
        - compliance://base/ssh
```

## Scanning a Node in Chef Compliance
So [we've done this](http://www.anniehedgie.com/tour-of-chef-compliance), and it was so easy and fun. And this is for use in all stages of the development life cycle. And I'm a little embarrassed because I thought it might be complicated to upload your profile to Chef Compliance, but this is literally as complicated as it gets:

![](/assets/article_images/2016-06-09-inspec-basics-6/upload.png)

Just zip it up and upload it. You can also upload it from the command line using the `inspec compliance upload` command after you authenticate/log in with the `inspec compliance login` command.

When you're scanning on Chef Compliance, you can only use profiles that are stored on the Compliance server, not on Github or the Chef Supermarket. But I hear rumblings of the ability to store it on Chef Supermarket for use in Chef Compliance in the near future.

**You might not be able to scan on Chef Compliance.** Perhaps you don't want to store credentials on the Chef Compliance server. And you may not want the Chef Compliance server to see the nodes you're scanning for security purposes. 

## Running InSpec in an [audit cookbook](https://github.com/chef-cookbooks/audit)
So you'll probably want to use this [audit cookbook](https://github.com/chef-cookbooks/audit) if you've decided that you can't let the Chef Compliance server scan your machines. You can run this on your machine that's running Chef, and while the results of the scan will go to the Compliance server, the server will never have scanned your machine.  

This, too, is for use in all stages of the development life cycle and has the flexibility to have profiles stored in: 

  - [Github](https://github.com/)
  - [Chef Supermarket](https://supermarket.chef.io)
  - [Chef Compliance](http://www.anniehedgie.com/tour-of-chef-compliance)

## Concluding Thoughts
After learning InSpec at a very basic level, I was pleased with how approachable and easy to grasp it was. And the more I've worked with it, I've come to find InSpec quite versatile. It's been a great study tool for me because I was able to start out so simply and build on that knowledge. I think that's the key to learning any new skill, really - start with small, manageable chunks and work your way up. Try not to get discouraged by what you don't know, and focus on what you do know. 

Go to Day 7: [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)