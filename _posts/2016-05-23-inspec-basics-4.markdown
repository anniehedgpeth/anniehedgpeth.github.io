---
layout: post
title:  "InSpec Tutorial: Day 4 - Custom Matchers"
date:   2016-05-23 05:00:00
categories: chef, chef compliance, inspec, security, inspec tutorial
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial
image: /assets/article_images/2016-05-23-inspec-basics-4/inspec-basics-4.jpg
image2: /assets/article_images/2016-05-23-inspec-basics-4/inspec-basics-4-mobile.jpg
---
Before you start today's [InSpec](https://github.com/chef/inspec) basics tutorial, be sure to get up to date with the first three days! 
  
  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  
I was telling you about how at first I was really a little concerned with how I'd know if I was picking the correct file resource for a control. Being the newb that I am, I was overwhelmed with the choices on the [InSpec Resource](https://docs.chef.io/inspec_reference.html) page. Honestly, much of it was Greek to me.
  
The first two controls were easy enough because to me, someone who knows little about all this, they were really intuitive. For the [first one](http://www.anniehedgie.com/inspec-basics-2), I ran a command and asked it to match the output. For the [second one](http://www.anniehedgie.com/inspec-basics-3) I searched inside a file for content. Easy enough. And when I got to the third one - 1.5.1, I really started learning how to search for the proper resource and matcher even if I didn't really know what it all totally means.  

Let's get started and I'll show you what I mean.
  
## Ingredients
Don't forget our bazillion windows. Open these up, and make sure your CentOS vm is up and running.
  
  - [Nathen Harvey's workshop](https://github.com/chef-training/workshops/tree/master/InSpec)
  - [InSpec Reference page](https://docs.chef.io/inspec_reference.html)
  - [Rubular](http://rubular.com/)
  - [Download the PDF of the CIS CentOS Linux Benchmark](https://benchmarks.cisecurity.org/tools2/linux/CIS_CentOS_Linux_6_Benchmark_v1.1.0.pdf)
  - your text editor  
  - your command line
  
## Workflow
At first I thought I'd have to make a flowchart because the workflow would change depending upon the resource that was needed, but I've found that that's not really the case. This workflow has proven to be expedient and efficient for me.  

1. [Go to Harvey's workshop and look up our control](#go-to-harveys-workshop-and-look-up-our-control)
2. [Find and read the control in the CIS pdf](#find-and-read-the-control-in-the-cis-pdf)
3. [Run the audit command on our command line](#run-the-audit-command-on-our-command-line) 
4. [If audit fails, run remediation](#if-audit-fails-run-remediation)
5. [Go to the Inspec Reference page to decide on a resource and matcher to use](#go-to-the-inspec-reference-page-to-decide-on-a-resource-and-matcher-to-use)
6. [Construct a regex in Rubular](#construct-a-regex-in-rubular)
7. [Finish the control in your text editor](#finish-the-control-in-your-text-editor)
8. [Test](#test)

### 1. Go to Harvey's workshop and look up our control
So head over to [Nathen Harvey's workshop](https://github.com/chef-training/workshops/tree/master/InSpec), and let's do the third one this time.

![](/assets/article_images/2016-05-23-inspec-basics-4/01-Harvey.png)

### 2. Find and read the control in the CIS pdf
Open the [CIS CentOS Linux 6 Benchmarks v1.1.0](https://benchmarks.cisecurity.org/tools2/linux/CIS_CentOS_Linux_6_Benchmark_v1.1.0.pdf) that you downloaded, then look for our command inside there: 1.5.1. And now let's fill in [those first few lines](http://www.anniehedgie.com/inspec-basics-2#find-and-read-the-control-in-the-cis-pdf) with the info we need from the CIS documentation.

```ruby
control "cis-1-5-1" do
  impact 1.0
  title "1.5.1 Set User/Group Owner on /etc/grub.conf (Scored)"
  desc "Set the owner and group of /etc/grub.conf to the root user."
```

### 3. Run the audit command on our command line
Remember that the CIS benchmark will tell us the command to run to see if we're compliant. Let's run that now:

```
stat -L -c "%u %g" /etc/grub.conf | egrep "0 0"
``` 

So I had to read [this](http://superuser.com/questions/508881/what-is-the-difference-between-grep-pgrep-egrep-fgrep) to understand that command, but all you really need to know is that when you run it, it should come back with `0 0`. If it doesn't, then run the remediation. 

### 4. If audit fails, run remediation
Should your audit fail, it looks like it's pretty simple to fix. Just run the remediation command that the CIS gives you.

```
chown root:root /etc/grub.conf
```

### 5. Go to the Inspec Reference page to decide on a resource and matcher to use
Okay, we're finally to the fun part. When I first did this control I thought that it would require a [command resource](http://www.anniehedgie.com/inspec-basics-2) because the remediation can be done by a command instead of editing a file. So I tried this:

```ruby
control "cis-1-5-1" do
  impact 1.0
  title "1.5.1 Set User/Group Owner on /etc/grub.conf (Scored)"
  desc "Set the owner and group of /etc/grub.conf to the root user."
  describe command('stat -L -c "%u %g" /etc/grub.conf') do
    its('stdout') { should match '0 0' }
  end
end
```

And, of course, it worked. But it's not exactly using the InSpec framework in the way it was created because it's just using the command that CIS gives you, and it doesn't take advantage of the simplicity of InSpec. InSpec's strength is that it can be understood by anyone. That is the real beauty of its simplicity.

I reread the CIS description that stated that it was simply looking at a file to make sure its owner and group were set to the root user. (Kind of crazy how things make a lot more sense when you actually read them a second time.)

So now when I go to the [Inspec Reference](https://docs.chef.io/inspec_reference.html) page and look at the options in the right sidebar menu, I'm still drawn to the *file* resources since we're looking at a file. Make sense? But which one? Let's take a look at what we have to choose from in the [*file*](https://docs.chef.io/inspec_reference.html#file) resources.

[![](/assets/article_images/2016-05-23-inspec-basics-4/02-owner.png)](https://docs.chef.io/inspec_reference.html#owner)
[![](/assets/article_images/2016-05-23-inspec-basics-4/03-group.png)](https://docs.chef.io/inspec_reference.html#group)

Well, what do you know? Exactly what we needed. So simple!

### 6. Construct a regex in Rubular
We won't need a regex for this one, so we can continue to #7.

### 7. Finish the control in your text editor
So you we're scrapping our control where we wrote out the command resource, right? Right. So now let's fill in the proper file resource with the [owner](https://docs.chef.io/inspec_reference.html#owner) and [group](https://docs.chef.io/inspec_reference.html#group) matchers and call it good (remember, we'll be using two today):

```ruby
control "cis-1-5-1" do
  impact 1.0
  title "1.5.1 Set User/Group Owner on /etc/grub.conf (Scored)"
  desc "Set the owner and group of /etc/grub.conf to the root user."
  describe file('/etc/grub.conf') do
    its('owner') { should eq 'root' }
    its('group') { should eq 'root'}
  end
end
```

### 8. Test
On your command line navigate to your workshop folder. Now run:

```
inspec exec test/1_spec.rb -t ssh://username@ipaddress --password 'PASSWORD' --sudo-password=PASSWORD --sudo
```

Hopefully your test passed. If not...back to the drawing board for you. 

## Concluding Thoughts
InSpec keeps getting easier and easier for me the more I practice. I've really enjoyed getting to know it better. On a broader level, it's teaching me that one doesn't need to know the whole of the technological world to get started in technology. One just needs willingness, an open mind, and a determination to push past the frustration of the unknown. Little by little, you add more things to the *known* pile, and you don't feel so lost.

I watched this video by [Kathy Sierra](https://www.youtube.com/watch?v=FKTxC9pl-WM) about how much one needs to know, how to retain it, and how to move forward. It was really so encouraging to me, and I want to give her a huge shoutout because it really spoke to me.   

As always, if you'd like to look at my [github repository](https://github.com/anniehedgpeth/inspec-workshop.git), feel free! I'm adding a few controls little by little. 

I'd love your feedback, so hit me up on [Twitter](https://twitter.com/anniehedgie)! 

Go to Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)