---
layout: post
title:  "InSpec Basics: Day 9 - Attributes"
date:   2016-10-27 12:00:00
categories: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, attributes, envrionment variables
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, attributes, envrionment variables
image: /assets/article_images/2016-10-05-inspec-basics-9/inspec-basics-9.jpg
image2: /assets/article_images/2016-10-05-inspec-basics-9/inspec-basics-9-mobile.jpg
redirect_to: https://hedge-ops.com/inspec-basics-9
---
Y'all, I was in [InSpec](http://inspec.io/) heaven a couple of weeks ago. I was on a [project](https://www.10thmagnitude.com/) where I was supposed to create an InSpec profile that tests the build and application configuration of a set of servers within a pipeline in [TeamCity](https://www.jetbrains.com/teamcity/) - smoke-tests. I had to translate a bunch of ServerSpec into InSpec and run the InSpec profile independently of the cookbook. Seems easy enough, but the challenge is testing all of the different environments and using different tests for each node spun up. The client also wanted it to be in one step for all the nodes, not a different step for each one.

But first, if you've missed out on any of my tutorials, you can find them here:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - Day 6: [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
  - Day 7: [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)
  - Day 8: [Regular Expressions](http://www.anniehedgie.com/inspec-basics-8)

If you'd like to follow along, then you're welcome to go clone this [practice InSpec profile](https://github.com/anniehedgpeth/practice-inspec-profile).

## Here's what we'll cover:
1. [Assessing our needs](#assessing-our-needs)
2. [Declaring the Attributes](#declaring-the-attributes)
3. [Use the attributes in an if statement](#use-the-attributes-in-an-if-statement)
4. [Create different attributes yamls to run the different tests](#create-different-attributes-yamls-to-run-the-different-tests)
5. [Concluding Thoughts](#concluding-thoughts)

# Assessing our needs
So let's say that you have two different roles that you want to test: database and webserver. And let's keep it simple and just test one environment where you spin up one machine for each role. 

That means that we're going to need two different sets of tests:
 - 1 for client tests
 - 1 for server tests

If you're following along in the [practice InSpec profile](https://github.com/anniehedgpeth/practice-inspec-profile), then you'll see that there are three different sets of tests (well, really just one test in each control, but you get the picture.) We're going to set it up so that we can run one test for each role.

Now, the big bummer of this is that attributes don't work for InSpec in Test Kitchen just yet like they do for [recipes](https://docs.chef.io/config_yml_kitchen.html), but I think that would be great if they did! (hint hint) Maybe sometime soon we'll get that.

# Declaring the Attributes
Let's go over to our control and add the attributes hard-coded with a default value and see what it does. We're going to declare the attributes above where we're using them. So add this above your `client` control.

```ruby
role = attribute('role', default: 'base', description: 'type of node that the InSpec profile is testing')
```

# Use the attributes in an IF statement
Now that the attributes are declared, we'll need to wrap our controls in an `if` statement so that it only tests that block when we want it to. Your `client` control block is going to end up looking like this:

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

You're saying, "If the node you're looking at is a client or base, then run this control block." You'll do the same for the `server` control:

```ruby
if ['server', 'base'].include? role
  control "Testing only server" do
    title "Tests for Server"
    desc "The following tests within this control will be used for server nodes."
    describe user('server') do
      it { should exist }
    end
  end
end
```
What happens when you run it now? Well, nothing different yet, so let's make that happen.

# Create different attributes yamls to run the different tests
We'll need to add a few attributes files to our profile to call on to change those roles. These are going to be yaml files, and while you may put them anywhere you want, I think it's nice if they get their own directory inside of the profile. Go ahead and create these now.

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

We're going to run these tests on our local machine, and while we know, obviously, that these tests will fail, we're going to see how the attributes ran the different tests.

So then, let's watch it run just the tests for only base and client by running:

```
inspec exec . --attrs attributes/client-attributes.yml
```
<img src='/assets/article_images/2016-10-05-inspec-basics-9/attributes-5.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

See how it didn't include the server only tests?

And now let's watch it run the tests for just base and server roles:
```
inspec exec . --attrs attributes/server-attributes.yml
```

<img src='/assets/article_images/2016-10-05-inspec-basics-9/attributes-6.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

See how it didn't include the tests for client only?

And there you go! That's a simple guide to attributes! 

# Concluding Thoughts
I love this feature. It gives a lot of flexibility and control, and you can use it in a lot of different ways. The trick is to hard-code the attributes first to make sure it's working. 

So just a little job update - I'm loving it over here at 10th Magnitude. I'm learning so much. Sure, I ask some dumb questions from time to time, and I feel really dumb about them later, but I am in the perfect position to learn a ton. {{Feeling grateful}}

Go to Day 10: [Attributes with Environment Variables](http://www.anniehedgie.com/inspec-basics-10)