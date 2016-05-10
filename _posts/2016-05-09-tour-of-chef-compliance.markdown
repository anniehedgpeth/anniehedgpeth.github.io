---
layout: post
title:  "Tour of Chef Compliance"
date:   2016-05-08 08:00:00
categories: chef, chef compliance, inspec, security
tags: chef, chef compliance, inspec, security
image: /assets/article_images/2016-05-09-tour-of-chef-compliance/tour-of-chef-compliance.jpg
image2: /assets/article_images/2016-05-09-tour-of-chef-compliance/tour-of-chef-compliance-mobile.jpg
---
Last week I showed you [how to get set up](http://www.anniehedgie.com/setting-up-compliance) to use [Chef Compliance](https://www.chef.io/compliance/), so now that you're ready, let's take a look at just what this tool can do for us.

Today we're going to take a very basic tour of Chef Compliance - easy breezy - just to get the feel of it. So what we're going to do is 1) use Chef Compliance to scan the Chef Compliance server that we just made, because why not? That needs to be clean, too, right? 2) We'll take one of the failures that it gives us, 3) go in and fix it manually, and then 4) rescan to make sure it was remediated.

## Add a node

After you log in, you'll be at a screen that looks like this. Click on **Add Node**   

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/01-add-node.png)

Then you'll need to fill all of this out.

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/02-add-server.png)

  - **Enter nodes (IPs or hostnames):** Add yours; mine was amh.southcentralus.cloudapp.azure.com
  - **Add to environment:** just pick any category of machine (i.e. test, production, development)
  - **Access:** ssh
  - **Username:** *enter yours*
  - **Password:** *enter yours*
  - Then click **Add 1 node**

## Scan it
Now **check** your newly added server, and click **Scan**.

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/03-scan.png)

We need to tell it which profile we need to scan it against, so let's choose: **cis/cis-ubuntu14.04lts-level1**. Then click **Scan Now** and wait for the magic to happen.

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/04-cis.png)

After your scan is complete, your summary of compliance failures will appear.

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/05-scan-report.png)

## Surprise! You have failures!
52 of them to be exact. The very first one says **Set Password Expiration Days**.
  
  - Click on that (honestly, I don't know if you *have* to click it, but it can't hurt).
  
![](/assets/article_images/2016-05-09-tour-of-chef-compliance/06-errors.png)

  - We need to learn about the rule that defines it as a failure, so click on **Compliance** on the top left.
  - Then find the profile that you used to scan against and click on it: **ubuntu14.04lts-level1**

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/07-compliance.png)

Let's take a look at the [InSpec](https://github.com/chef/inspec) code that wrote the rule that found this failure. It's going to tell us which folder we need to look in to find the file that needs to be edited and what it needs to be edited to.

![I had to edit this image so that you could see the text that didn't wrap.](/assets/article_images/2016-05-09-tour-of-chef-compliance/08-error-details.png)
It's a bit small, but it says:

``` ruby
control "xccdf_org.cisecurity.benchmarks_rule_10.1.1_Set_Password_Expirations_Days" do
  title "Set Password Expiration Days"
  desc "The PASS_MAX_DAYS parameter in /etc/login.defs allows an administrator to force passwords to expire once they reach a defined age. It is recommended taht the PASS_MAX_DAYS parameter be set to less than or equal to 90 days."
  impact 1.0
  describe file("/etc/login.defs")do
    its(:content) { should match /^\s*PASS_MAX_DAYS\S+90/ }
  end
```
So I don't read or write InSpec, but what I find pretty cool is that we can figure out what it says pretty easily anyway. Let's go line by line and understand what this means.


``` ruby
control "xccdf_org.cisecurity.benchmarks_rule_10.1.1_Set_Password_Expirations_Days" do
```

So that's the rule that it says our server broke, right? Right.

``` ruby
  title "Set Password Expiration Days"
```

When we open up the file, we're going to see a section with this as the title. 

``` ruby
  desc "The PASS_MAX_DAYS parameter in /etc/login.defs allows an administrator to force passwords to expire once they reach a defined age. It is recommended taht the PASS_MAX_DAYS parameter be set to less than or equal to 90 days."
```

This is a full description of the command so that we understand exactly what it wants from us. So now we know that our `PASS_MAX_DAYS` must be set to 90 days or less. That must mean that it's currently set at greater than 90 days.

``` ruby
  describe file("/etc/login.defs") do
```

This is telling us that this is the file that we need to change and that it's in the `etc` folder. Got it! 

``` ruby
    its(:content) { should match /^\s*PASS_MAX_DAYS\S+90/ }
```

And there's the code that's making it all happen. So now we're ready to go fix it manually!

## Let's fix it
Our goal is to [automate these fixes](https://www.chef.io/), right? But for now, we're learning and experimenting, so we're going to have some fun by fixing one of these failures manually.  So let's get ready to clean up some messes - be still my OCD little heart. 

So first we need to open our terminal and ssh to our vm. So type ssh then your username @ your fully qualified domain name. 

```
ssh username@fqdn
```

Now we need to go to the folder that holds the offending command, so let's change directory to the `etc` folder.

```
cd /etc
```

So now that we're in that folder, we need to open up the offending file using our text editor, Nano.

``` 
sudo nano login.defs
```

Let's look for the text that we need to edit. We can search for it using `ctrl+w` to search for `Pass`.

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/09-edit-file.png)

And there it is! It's currently set to 99999 days, and all we have to do is change it to 90 or less to make it compliant.

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/09b-edit-file.png)

When you're finished, hit `ctrl+o` (write out) to save, then `enter`. Then `ctrl+x` to exit.

## Let's scan again
So now let's go back to our Chef Compliance dashboard, check our server box, and scan it again. 

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/10-rescan.png)

Now when we look at our list of failures, 

![](/assets/article_images/2016-05-09-tour-of-chef-compliance/11-error-remediated.png)

...the one that we worked on that said **Set Password Expiration Days** isn't there anymore! Woohoo! We remediated it! Feels good, doesn't it? Only 51 more to go... 

## Concluding Thoughts
So, true confession, after I wrote the [tutorial for setting up Chef Compliance](http://www.anniehedgie.com/setting-up-compliance), I was like, 'Uh...seriously? Is it supposed to be this hard?' But the creators of the software -totally sweet and super smart (and tall) guys- are aware and are working on that, so yay! 

![(1) No amount of filters can fix a bad hair day, and 2) that's a really cool Chef apron that I should have had a guy wear so that I wasn't stereotypically wearing an apron as the only woman in the pic - dangit)](/assets/article_images/2016-05-09-tour-of-chef-compliance/dinner_at__michael_and_annie_s_home__.png)


But then I started playing around with the actual program, and it is so incredibly easy to use and intuitive. I feel like it should be harder because it's such a valuable tool in terms of how it changes the security game, making it so much safer to get to production. 

So now that we understand how cool [Chef Compliance](https://www.chef.io/compliance/) is, I'll be exploring and learning more about [InSpec](https://www.chef.io/inspec/) so that I can learn how to create my own profiles to test against. I hope you'll stay tuned!