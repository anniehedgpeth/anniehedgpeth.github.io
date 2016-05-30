---
layout: post
title:  "InSpec Tutorial: Day 5 - Creating a Profile"
date:   2016-05-25 05:00:00
categories: chef, chef compliance, inspec, security, inspec tutorial, profile
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, profile
image: /assets/article_images/2016-05-25-inspec-basics-5/inspec-basics-5.jpg
image2: /assets/article_images/2016-05-25-inspec-basics-5/inspec-basics-5-mobile.jpg
---

Go to http://downloads.chef.io/chef-dk
- follow instructions

Open a terminal and type chef to make sure it's installed

Install Virtual Box https://www.virtualbox.org/wiki/Downloads
Install Vagrant https://www.vagrantup.com/downloads.html
 - creates vm's 

Open a terminal and type vagrant to make sure it's installed

Create a repo on github called inspec-workshop-cookbook
Clone it locally 

```git clone https://github.com/anniehedgpeth/inspec-workshop-cookbook.git```

Create a cookbook
```chef generate cookbook inspec-workshop-cookbook```

Open the cookbook in text editor
Do initial commit

Edit metadata

.kitchen.yml
  - provisioner=chef zero
    - to provision means to make the machine into what it's told to be 
    Vagrant builds the house, and chef zero furnishes it.
    
    