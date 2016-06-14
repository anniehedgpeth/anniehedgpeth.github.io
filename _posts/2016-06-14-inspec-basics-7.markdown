---
layout: post
title:  "InSpec Basics: Day 7 - How to Inherit a Profile from Chef Compliance Server"
date:   2016-06-13 03:00:00
categories: chef, chef compliance, inspec, security, inspec tutorial, profile, kitchen, cookbook, profile inheritance
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, profile, kitchen, cookbook, profile inheritance
image: /assets/article_images/2016-06-14-inspec-basics-7/inspec-basics-7.jpg
image2: /assets/article_images/2016-06-14-inspec-basics-7/inspec-basics-7-mobile.jpg
---
I'm back again today with yet another InSpec tutorial. As always, if you haven't dipped your toe into the [InSpec](https://github.com/chef/inspec) pool yet, now you can:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - Day 6: [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
 
Perhaps you've been using Compliance, but the profiles in there are not exactly what you need. Maybe you want to take a few controls out and add a few others. Today we'll be discussing how you can do that by inheriting a profile to modify for use in [Chef Compliance](https://www.chef.io/compliance/).  
 
It's pretty simple to do; the only catch is that you have to use it within the Compliance server, nowhere else. It would be pretty cool if you could inherit a profile to use with the audit cookbook or in Kitchen, but they're not quite ready with the new dependency management feature yet. I'll update this post when I hear that it's there. 

# Overview
1. Determine which controls are not needed from the Compliance server profile
2. Change the controls in an inherited profile 
3. Using the inherited profile on Chef Compliance

# Determine which controls are not needed from the Compliance server profile
You have a failing report because there are a bunch of controls in the profile that either you don't need or you need them to be different. Because of that, you'll need to know how to change what you need to change to get the job done for your company and their needs. Let's look at an example. We can go to our Compliance dashboard, find a report, and take a look at the failures:

![](/assets/article_images/2016-06-14-inspec-basics-7/failure.png)

For this tutorial, let's focus on the first one: Set Password Expiration Days.

Let's say, also, that you want the password expiration to be set to 30 days instead of 90. The way we'll do that is by scanning with an inherited version of that profile that *ignores* that particular control and *adds* another control that tests for 30 days. 

Let's go find it. We can see that it was the **cis-ubuntu14.04lts-level1 profile**, so let's go to the Compliance tab and find that profile. Click on it, and find the offending control.

![](/assets/article_images/2016-06-14-inspec-basics-7/control.png)

What you'd do here is make a list of all of the controls that you'd need to change. Right now, we just need this one, so I'm going to copy and paste that one control name.

# Change the controls in an inherited profile

First we'll need to go back to our command line and get started by creating a new profile.

```
inspec init profile <profile-name>
```

![](/assets/article_images/2016-06-14-inspec-basics-7/profile.png)

Now we can go open that in our editor and open up our example.rb file. We'll find this already there.

```ruby
describe file('/tmp') do
  it { should be_directory }
end

# you add controls here
control 'tmp-1.0' do                        # A unique ID for this control
  impact 0.7                                # The criticality, if this control fails.
  title 'Create /tmp directory'             # A human-readable title
  desc 'An optional description...'
  describe file('/tmp') do                  # The actual test
    it { should be_directory }
  end
end
```

But the nice guys at InSpec have also given us this handy little control from [their git page](https://github.com/chef/inspec/blob/master/examples/inheritance/controls/example.rb), so let's copy that.

```ruby
include_controls 'profile' do
  skip_control 'tmp-1.0'
end
```

So I want to tell it to still use that profile, but skip the offending control. But I'm also going to add another control that is specific to my company's needs. So I'm just copying the old one exactly and changing the number of days for which it's testing.

But be mindful! Obviously, that's not going to work if I'm telling it to skip the control and then I don't change the name of the control that I'm adding, right? So notice that I added `To_30` to the end of the control name that I'm adding. 

```ruby
include_controls 'cis/cis-ubuntu14.04lts-level1' do
  skip_control 'xccdf_org.cisecurity.benchmarks_rule_10.1.1_Set_Password_Expiration_Days'

  control "xccdf_org.cisecurity.benchmarks_rule_10.1.1_Set_Password_Expiration_Days_To_30" do
    title "Set Password Expiration Days"
    desc  "The PASS_MAX_DAYS parameter in /etc/login.defs allows an administrator to force passwords to expire once they reach a defined age. It is recommended that the PASS_MAX_DAYS parameter be set to less than or equal to 30 days."
    impact 1.0
    describe file("/etc/login.defs") do
      its(:content) { should match /^\s*PASS_MAX_DAYS\s+30/ }
    end
  end
end

```

# Using the inherited profile on Chef Compliance
You should be good to go now. All you need to do is zip up your profile, upload it to Chef Compliance, and run it! There you see the control that we changed. 

![](/assets/article_images/2016-06-14-inspec-basics-7/compliance.png)

# Concluding Thoughts
I think that the ability to create inherited profiles is absolutely necessary when seriously using Chef Compliance. It will be even better when they develop the dependency management feature so that we can use these inherited profiles outside of Compliance. 

I did have a few minor issues with this process that I'm sure they'll fix soon, but it's something that you can be aware of so it doesn't slow you down. 

First of all, I had a really minor error; I was missing an `end` and didn't notice. So when I tried to upload my compressed profile, it didn't do anything - not even give me an error message that I could understand. It took me creating an [embarassingly simple issue on github](https://github.com/chef/inspec/issues/789) to learn of my typo.

The other thing that was kind of a bummer is that I couldn't run it locally first before uploading it. So that embarassingly tiny error went unnoticed and caused me a bit of a headache. 

All in all, errors aside, the process was pretty simple, and it taught me a new concept since I didn't know what inheritance was before I learned this process. 