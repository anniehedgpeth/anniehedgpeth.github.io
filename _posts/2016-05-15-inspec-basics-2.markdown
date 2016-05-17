---
layout: post
title:  "InSpec Tutorial: Day 2 - Command Resource"
date:   2016-05-17 08:00:00
categories: chef, chef compliance, inspec, security
tags: chef, chef compliance, inspec, security, tutorial
image: /assets/article_images/2016-05-17-inspec-basics-2/inspec-basics-2.jpg
image2: /assets/article_images/2016-05-17-inspec-basics-2/inspec-basics-2-mobile.jpg
---
Last week we walked through a really basic [Hello World](http://www.anniehedgie.com/inspec-basics-1) InSpec tutorial, just to get our feet wet, and today in our [InSpec](https://www.chef.io/inspec/) workshop, we'll be diving a little deeper and creating this:

```ruby
control "cis-1-2-1" do                      
  impact 1.0                                
  title "1.2.1 Verify CentOS GPG Key is Installed (Scored)"
  desc "CentOS cryptographically signs updates with a GPG key to verify that they are valid."
  describe command('rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey') do
   its('stdout') { should match /CentOS 6 Official Signing Key/ }
  end
end
```

But first make sure that you go through [last week's tutorial](http://www.anniehedgie.com/inspec-basics-1) so that we can make sure you have all of the proper software installed and updated.

## Nathen Harvey's InSpec Workshop
[Nathen Harvey](http://nathenharvey.com/) has a [fantastic InSpec workshop](https://github.com/chef-training/workshops/tree/master/InSpec) that I'm going through right now, and he talks about it on [Chef's YouTube channel](https://youtu.be/dEPe-JXRjVU), too. Throughout my InSpec tutorial series, I'll be showing you some basics for getting through his workshop successfully. Think of my tutorial as a remedial class before you take Harvey's workshop, or some extra tutoring along the way. 

How about we just dive right in?

## But first...your VM
Head over to [Azure](https://portal.azure.com) and get yourself a nice, shiny [CentOS 6 VM](http://www.openlogic.com/products-services/services/cloud-services/azure) and come back. It'll need to be set up to enable non-interactive `sudo` access for the machine, so to do that, we have a bit of a [workaround](https://github.com/chef/train/issues/60) to do real quick. Go to your command line and ssh into your machine. Once you're in, we need to edit `/etc/sudoers.d/username` (obvi use your username, right?). So you'll need to enter

```
sudo nano /etc/sudoers.d/username
```

Then just add this to the file, save, and exit.

```
username ALL=(root) NOPASSWD: ALL
Defaults!ALL !requiretty
```

That's it! Now we're ready to roll.

## Ingredients
You're going to need about a bazillion windows open for our little workflow to happen, so open up these:
  
  - [Nathen Harvey's workshop](https://github.com/chef-training/workshops/tree/master/InSpec)
  - [InSpec Reference page](https://docs.chef.io/inspec_reference.html)
  - [Rubular](http://rubular.com/)
  - [Download the PDF of the CIS CentOS Linux Benchmark](https://benchmarks.cisecurity.org/downloads/show-single/?file=centos6.110)
  - your text editor  
  - your command line

## Workflow
This is what our basic workflow for the workshop is going to look like. 

1. [Go to Harvey's workshop and look up our control](#go-to-harveys-workshop-and-look-up-our-control)
2. [Find and read the control in the CIS pdf](#find-and-read-the-control-in-the-cis-pdf)
3. [Run the audit command on our command line](#run-the-audit-command-on-our-command-line) 
4. [If audit fails, run remediation](#if-audit-fails-run-remediation)
5. [Go to the Inspec Reference page to decide on a resource and matcher to use](#go-to-the-inspec-reference-page-to-decide-on-a-resource-and-matcher-to-use)
6. [Construct a regex in Rubular](#construct-a-regex-in-rubular)
7. [Finish the control in your text editor](#finish-the-control-in-your-text-editor)
8. [Test](#test)

### 1. Go to Harvey's workshop and look up our control
So head over to [Nathen Harvey's workshop](https://github.com/chef-training/workshops/tree/master/InSpec), and note the very first one on the list because that's what we're after.
![](/assets/article_images/2016-05-17-inspec-basics-2/04-nathen-harvey.png)

### 2. Find and read the control in the CIS pdf
Open the [CIS CentOS Linux 6 Benchmarks v1.1.0](https://benchmarks.cisecurity.org/downloads/show-single/?file=centos6.110) that you downloaded, then look for our command inside there. Once you've found it, we're going to snag some of that information for our control. Look at the first three lines again.

```ruby
control "cis-1-2-1" do                      
  impact 1.0                                
  title "1.2.1 Verify CentOS GPG Key is Installed (Scored)"
  desc "CentOS cryptographically signs updates with a GPG key to verify that they are valid."
``` 

Notice that I chose the `control` to be the CIS number. I could have been more specific, obviously, but I didn't for simplicity's sake. *Profile Applicability* determines the `impact` field. And the `title` and `desc` come straight out of there word for word. 

Let's open up our text editor and create a new file. I called mine `1_spec.rb`. Then enter all of that in - the control, impact, title, and desc. 

### 3. Run the audit command on our command line
Let's now run the audit command there that the CIS gives us:

```
rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey
```

They don't tell you what the output is supposed to be, but we can guess that our audit passed because it didn't say it failed. So now we know that apparently that's the output that it gives when the test is run and it passes. Score! So let's copy and paste that text somewhere to use in a sec. 
 
![](/assets/article_images/2016-05-17-inspec-basics-2/01-audit-command.png)

### 4. If audit fails, run remediation
We don't have to do that this time since we passed, so we'll hold off on this step until another time when we need it.

### 5. Go to the Inspec Reference page to decide on a resource and matcher to use
So there are a whole bunch of different audit resources to use for creating tests (and this [InSpec reference page](https://docs.chef.io/inspec_reference.html) has all of them). An *audit resource* is basically the suggested tool to use in order to code your control. The two heavy hitting resources are going to be *file* and *command*. We used the *file resource* with the *content matcher* [last week](http://www.anniehedgie.com/inspec-basics-1) when we were searching for text within a file. 

So let's take a look at the reference page and decide which to use now. In the menu on the right, you'll see every possible resource. So what do we know about our test? When we run the audit command it gives us a standard output, right? So let's find *command* and - what do you know - it has a *stdout* option under *Matchers*. A *matcher* is just like it sounds - we want to match what's in our test with what the stdout is.

![](/assets/article_images/2016-05-17-inspec-basics-2/03-inspec-resources.png)

(Full disclosure, I'm oversimplifying the process just a little bit, but I'm only doing that for the sake of this being the first one in the workshop. I'll explain as we dive into it more and more how to choose which audit resources to use. (I see a flowchart in our near future, perhaps.))

Alright, so when we click on *stdout* from the menu on the right, it shows us this test to use when we need to match a standard output.

![](/assets/article_images/2016-05-17-inspec-basics-2/05-stdout.png)

Let's copy that and enter it into our text editor after the 4 lines we added earlier. Now let's change the `describe command` to have the audit test from the CIS benchmarks. In the next step we'll change the `should match` matcher, so hold off for now.

```ruby
describe command('rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey') do
   its('stdout') { should match (/[0-9]/) }
end
```

### 6. Construct a regex in Rubular
Remember that standard output that we copied and pasted earlier in step 3? Grab that and head over to your browser that has [Rubular](http://rubular.com/) opened. Now paste that standard output into *Your test string*. 

Now we're going to pick out a shortened, regular expression out of that mess, enter it into *Your regular expression*, and if your *Match result* has it highlighted, then it's happy and you're safe to use just that shortened *regex* in your command. So copy that regex and get ready to paste it. 

[![](/assets/article_images/2016-05-17-inspec-basics-2/02-rubular.png)](http://rubular.com/r/7969HPaj2n)

### 7. Finish the control in your text editor
Now we're ready to add our matcher to complete our control! So paste your regex into the `should match`, add another `end` at the bottom, and it should all like this:
 
```ruby
control "cis-1-2-1" do                      
  impact 1.0                                
  title "1.2.1 Verify CentOS GPG Key is Installed (Scored)"
  desc "CentOS cryptographically signs updates with a GPG key to verify that they are valid."
  describe command('rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey') do
   its('stdout') { should match /CentOS 6 Official Signing Key/}
  end
end
```

### 8. Test
On your command line navigate to your workshop folder. Now run:

```
inspec exec test/1_spec.rb -t ssh://username@ipaddress --password 'password'
```

For the command line newbs like me, `test` is the folder you've put your file in. `username`, `ipaddress`, and `password` are for your CentOS vm. 

Hopefully your test passed. If not...back to the drawing board for you. 

## Concluding Thoughts
This is still a very nebulous process for me. I'm not quite sure how I'm ever going to know enough to be able to choose the right audit resources, and that gives me a little anxiety. I'm hoping that it dissipates the more I progress through Harvey's workshop, though. 

It would be great if you tracked and shared your work in a [git repository](https://github.com)! Here's [mine](https://github.com/anniehedgpeth/inspec-workshop.git). Anyone have any tricks of the trade for me?