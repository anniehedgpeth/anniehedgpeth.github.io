---
layout: post
title:  "InSpec Tutorial: Day 3 - File Resource"
date:   2016-05-20 08:00:00
categories: chef, chef compliance, inspec, security, inspec tutorial
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial
image: /assets/article_images/2016-05-20-inspec-basics-3/inspec-basics-3.jpg
image2: /assets/article_images/2016-05-20-inspec-basics-3/inspec-basics-3-mobile.jpg
---
Welcome back! If you're just now joining me, then you'll want to take a look at the first two days in this little Inspec journey.
  
  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  
  In [Day 2](http://www.anniehedgie.com/inspec-basics-2) I told you that the two resources that you'll use most with Inspec are [*command*](https://docs.chef.io/inspec_reference.html#command) and [file](https://docs.chef.io/inspec_reference.html#file). The *command resource* basically reads the output of the command that you give it, and you pass or fail based on that output. And the *file resource* basically passes or fails based on what the control says the different aspects of that file should or shouldn't be. 
  
  So far I've found the simplest *file resource* to be the [*content matcher*](https://docs.chef.io/inspec_reference.html#content). Today we're going to do just that. You're going to write a control that looks for specific text within a file. Easy but mighty.
  
  So do you remember our workflow and windows we need open?
  
## Ingredients
Open these up, and make sure your CentOS vm is up and running.
  
  - [Nathen Harvey's workshop](https://github.com/chef-training/workshops/tree/master/InSpec)
  - [InSpec Reference page](https://docs.chef.io/inspec_reference.html)
  - [Rubular](http://rubular.com/)
  - [Download the PDF of the CIS CentOS Linux Benchmark](https://benchmarks.cisecurity.org/downloads/show-single/?file=centos6.110)
  - your text editor  
  - your command line
  
## Workflow
Even though we are dealing with a file resource this time, the workflow will still be the same. I found that when I follow this workflow exactly, it goes way faster and I make fewer mistakes.  

1. [Go to Harvey's workshop and look up our control](#go-to-harveys-workshop-and-look-up-our-control)
2. [Find and read the control in the CIS pdf](#find-and-read-the-control-in-the-cis-pdf)
3. [Run the audit command on our command line](#run-the-audit-command-on-our-command-line) 
4. [If audit fails, run remediation](#if-audit-fails-run-remediation)
5. [Go to the Inspec Reference page to decide on a resource and matcher to use](#go-to-the-inspec-reference-page-to-decide-on-a-resource-and-matcher-to-use)
6. [Construct a regex in Rubular](#construct-a-regex-in-rubular)
7. [Finish the control in your text editor](#finish-the-control-in-your-text-editor)
8. [Test](#test)

### 1. Go to Harvey's workshop and look up our control
So head over to [Nathen Harvey's workshop](https://github.com/chef-training/workshops/tree/master/InSpec), and let's do the second one since we did the first one last time.
![](/assets/article_images/2016-05-20-inspec-basics-3/01-nathen-harvey.png)

### 2. Find and read the control in the CIS pdf
Open the [CIS CentOS Linux 6 Benchmarks v1.1.0](https://benchmarks.cisecurity.org/downloads/show-single/?file=centos6.110) that you downloaded, then look for our command inside there: 1.2.2. [Remember](http://www.anniehedgie.com/inspec-basics-2#find-and-read-the-control-in-the-cis-pdf) how we need those bits of info to fill in our control?

```ruby
control "cis-1-2-2" do
  impact 1.0
  title "1.2.2 Verify that gpgcheck is Globally Activated (Scored)"
  desc "The gpgcheck option, found in the main section of the /etc/yum.conf file determines if an RPM package's signature is always checked prior to its installation."
```

You're a pro already. Moving right along...

### 3. Run the audit command on our command line
So the CIS benchmark will tell us the command to run to see if we're compliant. Let's run that now:

```
grep gpgcheck /etc/yum.conf
gpgcheck=1
``` 

That tells us that `gpgcheck` should equal `1`, right? So what if it doesn't? 

### 4. If audit fails, run remediation
We'll need to edit the file if the audit failed, so let's do that by ssh from the command line. Once you're in `sudo nano /etc/yum.conf'` Then add the text, write out `Ctrl+O`, and exit `Ctrl+X`. Then run the command again to make sure you fixed the problem.  

### 5. Go to the Inspec Reference page to decide on a resource and matcher to use
I told you already that *command* and *file* are the most common resources, and I told you already that we're going to be doing a file resource today. But how do we know that? Well, simple. The CIS audit wants us to look in a *file*. 

Let's head over to the [Inspec Reference](https://docs.chef.io/inspc/reference.html) page and look at the options in the right side bar menu.

[![](/assets/article_images/2016-05-20-inspec-basics-3/02-inspec-resource.png)](https://docs.chef.io/inspec_reference.html#id43)

We want to make sure that content exists within a file right? So we're going to see if we get a *match* for the *content* when we look inside that *file*.

 [![](/assets/article_images/2016-05-20-inspec-basics-3/03-content.png)](https://docs.chef.io/inspec_reference.html#id43)

### 6. Construct a regex in Rubular
The audit already gave us a regex, so we don't need to create one. On to #7.

*Update: I've since changed my tune on this a bit. Please see this post on [Regular Expressions](http://www.anniehedgie.com/inspec-basics-9) so that you can take care to use the best possible regex when necessary.*

### 7. Finish the control in your text editor
Okay, so you already had the first 4 lines, and now let's fill in the rest with the file resource:

```ruby
control "cis-1-2-2" do
  impact 1.0
  title "1.2.2 Verify that gpgcheck is Globally Activated (Scored)"
  desc "The gpgcheck option, found in the main section of the /etc/yum.conf file determines if an RPM package's signature is always checked prior to its installation."
  describe file('/etc/yum.conf') do
    its('content') { should match /gpgcheck=1/ }
  end
end
```

### 8. Test
On your command line navigate to your workshop folder. Now run:

```
inspec exec test/1_spec.rb -t ssh://username@ipaddress --password 'password'
```

Again, for the command line newbs like me, `test` is the folder you've put your file in. `username`, `ipaddress`, and `password` are for your CentOS vm. (I hope you got that, because I'll assume you know it next time!) 

Hopefully your test passed. If not...back to the drawing board for you. 

Now, if you plan to do more, then you'll hit a snag when you get to 1.5.3, so let me help you out now to save you some frustration. When you're running your test, use this instead:

```
inspec exec test/1_spec.rb -t ssh://username@ipaddress --password 'PASSWORD' --sudo-password=PASSWORD --sudo
```

I ran into controls that I had to have `sudo` access to run. So after that I decided just to run `--sudo-password=PASSWORD --sudo` every time. 

## Concluding Thoughts
I've written a lot more of these controls since last time, and each time it gets easier and easier. The first few took me a little while to navigate, and then I got stumped by the sudo issue, but after I got in a groove, each one took me just a minute or two. 

As always, if you'd like to look at my [github repository](https://github.com/anniehedgpeth/inspec-workshop.git), feel free! I'm adding a few controls little by little. 

I'd love your feedback, so hit me up on [Twitter](https://twitter.com/anniehedgie)! 

Go to Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)