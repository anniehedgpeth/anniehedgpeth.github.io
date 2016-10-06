---
layout: post
title:  "InSpec Basics: Day 9 - Attributes"
date:   2016-10-05 12:00:00
categories: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, attributes, envrionment variables
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, attributes, envrionment variables
image: /assets/article_images/2016-10-05-inspec-basics-9/inspec-basics-9.jpg
image2: /assets/article_images/2016-10-05-inspec-basics-9/inspec-basics-9-mobile.jpg
---
Y'all, I've been in [InSpec](http://inspec.io/) heaven lately. I'm on a [project](https://www.10thmagnitude.com/) right now where I'm supposed to create an InSpec profile that tests the build and application configuration of set of servers within a pipeline in TeamCity. I had to translate a bunch of ServerSpec into InSpec and run the InSpec profile independently of the cookbook. Seems easy enough, but the challenge is testing all of the different environments and using different tests for each node spun up. The client also wanted it to be in one step for all the nodes, not a different step for each one.

But first, if you've missed out on any of my tutorials, you can find them here:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - Day 6: [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
  - Day 7: [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)
  - Day 8: [Regular Expressions](http://www.anniehedgie.com/inspec-basics-8)

If you'd like to follow along, then you're welcome to go clone my repo and use this [practice InSpec profile](https://github.com/anniehedgpeth/practice-inspec-profile).

## Here's what we'll cover:
1. [Assessing our needs](#assessing-our-needs)
1. [Declaring the Attributes](#declaring-the-attributes)
2. [Use the attributes in an if statement](#use-the-attributes-in-an-if-statement)
3. [Make sure it runs in Kitchen](#make-sure-it-runs-in-kitchen)
4. [Create different attributes yamls to run the different tests](#create-different-attributes-yamls-to-run-the-different-tests)
5. [Concluding Thoughts](#concluding-thoughts)

# Assessing our needs
So let's say that you have two different roles that you want to test: database and webserver. And let's say in your development environment you only spin up one machine that has both roles on it. But in your QA environement you spin up a machine for each role. 

That means that we're going to need three different sets of tests:
 - 1 for dev which will be all in one 
 - 1 for client tests for QA
 - 1 for server tests for QA

If you're following along in the (practice InSpec profile)[https://github.com/anniehedgpeth/practice-inspec-profile], then you'll see that there are three different sets of tests (well, really just one test in each control, but you get the picture.) We're going to set it up so that we can run one test for each role.

These are obviously dummy tests that will fail, but in the output you'll see how it tried to test the nodes.

Now I'm going to use my old [practice elasticsearch cookbook](https://github.com/anniehedgpeth/elasticsearch_practice) to set up a couple of nodes, but I need to retrofit it a bit. If you want to clone that, too, you're welcome to. Just don't forget to change your `verifier` in your `.kitchen.yml`.

# Declaring the Attributes
Let's go over to our control and add the attributes hardcoded with a default value and see what it does. We're going to declare the attributes above where we're using them. So add this above your `client` control.

```ruby
role = attribute('role', default: 'base', description: 'type of node that the InSpec profile is testing')
```

What happens when you run `kitchen verify` now? Hopefully, you'll get a failure in your first suite for `server` user not existing and another in the second suite for the `client` user not existing.

# Use the attributes in an IF statement
Now that the attributes are declared, we'll need to wrap our controls in an `if` statement. So your `client` control block is going to end up looking like this:

```ruby
if ['client', 'base'].include? role
  control "Testing only client" do
    title "Tests for client"
    desc "The following tests within this control will be used for client nodes."
    describe user('client') do
      it { should exist }
    end
  end
end
```

You're saying, 'If the node you're looking at is a client or base, then run this control block.' You'll do the same for the `server` control:

```ruby
if ['server', 'base'].include? role
control "Testing only server" do
  title "Tests for Server"
  desc "The following tests within this control will be used for server nodes."
  describe user('server') do
    it { should exist }
  end
end
```

# Make sure it runs in Kitchen
What happens when you run `kitchen verify` now? Hopefully, you'll get a failure in your first suite for `server` user not existing and another in the second suite for the `client` user not existing. Like this...

<img src='/assets/article_images/2016-10-05-inspec-basics-9/attributes-2.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

Remember that our `client.rb` recipe in our cookbook has a `base` user in it, so the failures make sense if there are two users per instance.

# Create different attributes yamls to run the different tests
We'll need to add a few attributes files to call on to change those roles. These are going to be yaml files, and they will be in a directory that is sibling to your controls directory. Go ahead and create these now.

<img src='/assets/article_images/2016-10-05-inspec-basics-9/attributes-1.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

In each yaml, put the respective attribute values. 

```yaml
# In attributes.yml
role : base
```

```yaml
# In client-attributes.yml
role : client
```

```yaml
# In server-attributes.yml
role : server
```

We're not going to be able to run this as a `kitchen verify`, though, because I don't know of a way to do that and call the attributes in the `.kitchen.yml` of the cookbook.

Instead, we're going to run the `inspec exec` command. Remember that our username and password for vagrant is vagrant, and we're going to use this ssh for each node.

<img src='/assets/article_images/2016-10-05-inspec-basics-9/attributes-3.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

```
$ inspec exec practice-inspec.rb -t ssh://client@127.0.0.1:2222 -i ~/.ssh/id_rsa --password=vagrant
--attrs attributes/client-attributes.yml

$ inspec exec practice-inspec.rb -t ssh://client@127.0.0.1:2222 -i ~/.ssh/id_rsa --password=vagrant
--attrs attributes/server-attributes.yml
```

And there you go! 

# Concluding Thoughts
I love this feature. It gives a lot of flexibility and control, and you can execute it pretty much wherever you want in a pipeline without affecting anything else. Figuring it out if it's working or not can be tricky - even just in kitchen. The more I can do manually first, the better. That's why we hardcoded the attributes first. 

So just a little job update - I'm loving it. I'm learning so much. Sure, I ask some dumb questions from time to time, and I feel really dumb about them later, but I am in the perfect position to learn a ton. {{Feeling grateful}}