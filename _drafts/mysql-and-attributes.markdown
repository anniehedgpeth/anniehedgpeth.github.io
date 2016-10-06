---
layout: post
title:  "InSpec Basics: Day 9 - Attributes"
date:   2016-09-30 12:00:00
categories: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, attributes, envrionment variables
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, attributes, envrionment variables
image: /assets/article_images/2016-09-30-inspec-basics-9/inspec-basics-9.jpg
image2: /assets/article_images/2016-09-30-inspec-basics-9/inspec-basics-9-mobile.jpg
---
Y'all, I've been in [InSpec](http://inspec.io/) heaven lately. I'm on a [project](https://www.10thmagnitude.com/) right now where I'm supposed to create an InSpec profile that tests the build configuration of a machine within a pipeline in TeamCity. Seems easy enough, but the challenge is testing all of the different environments and making sure the correct Mysql passwords are entered in for each enviroment.

But first, if you've missed out on any of my tutorials, you can find them here:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - Day 6: [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
  - Day 7: [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)
  - Day 8: [Regular Expressions](http://www.anniehedgie.com/inspec-basics-8)

Okay, so I had to create a way in which my profile could read a variable for a password within a control. In this post I'll lead you through how I did that. 

## Here are the steps I took:
1. [Query the Mysql database manually](#query-the-mysql-database-manually)
2. [Make the password in the control into an attribute](#make-the-password-in-the-control-into-an-attribute)
3. [Make mysql password attribute configurable](#make-mysql-password-attribute-configurable)
4. [Create a rakefile](#create-a-rakefile)
5. [Test it out in TeamCity](#test-it-out-in-teamcity)

# Query the Mysql database manually
Before I could shoot off a bunch of code, I needed to make sure I could do it manually. So I needed to query the Mysql database in an ssh session. I was having issues doing this in Test Kitchen, so I knew the surefire way to get the proper output that I needed was to ssh into a real, live, development environment. So with access to that, I ssh'ed into it and ran the appropriate Mysql command to get the output I needed.

```
mysql -uUSER -pPASSWORD -e "SELECT User, Host FROM mysql.user;"
```

That stdout was exactly what I needed to write the proper control that I needed to test that I had the right users set up in my database. So now I could go back to my control and hardcode the password to see if it would test properly.

The control would end up looking something like this, but I added my hardcoded password as the default:

```ruby
password = attribute('password', default: 'HARDCODEDpasswordHERE', description: 'password for admin user in mysql datatbase')
db = mysql_session('admin', password)

describe db.query("SHOW DATABASES LIKE 'mydatabase'") do
  context "'mydatabase' database exists" do
    its('stdout') { should include 'mydatabase' }
  end
end

describe db.query('SELECT User, Host FROM mysql.user') do
  its('stdout') { should include 'admin	%' }
  its('stdout') { should include 'admin	localhost' }
  its('stdout') { should include 'user	%' }
  its('stdout') { should include 'user	localhost' }
end
```

After some trial and error (it took a while to get to this point), it worked, and I was ready to move on.

# Make the password in the control into an attribute

So you see up there how the password calls an [attribute](http://inspec.io/docs/reference/profiles/)? Well, eventually you will have to make an attributes yaml, but don't worry, for now we're still just going to hardcode the value. So make a directory in your profile called `attributes` or whatever you want. Then create a file in there called `attributes.yml`. Your yaml is going to look very simple, like this:

```
password: HARDCODEDpasswordHERE
```

Scroll down to the bottom of [THIS](http://inspec.io/docs/reference/profiles/) page for more info on it. Test that out and see if it works on your development environment. Do you remember how to do that? From your profile directory on your command line run:

```
inspec exec . -t ssh://USERNAME@DEVENV -i ~path/to/key/.ssh/id_rsa --attrs attributes/attributes.yml # OR --password=PASSWORD if not using a key
```

Does it work?! If so, great! Keep moving!

# Make mysql password attribute configurable

You still need a different password (maybe even user, too) for each environment that you run this on, right? So this hardcoded yaml isn't gonna cut it. I needed a different yaml for each environment. Enter the erb and rakefile. We're going to create a template that builds this yaml each time for us. 

If you haven't used an `erb` before, it's basically a template that creates files for you. You have to run a `rake` command before you run your InSpec profile so that your desired file, in this case, our `attributes.yml`, is generated from the `erb`. 

First thing we're going to do is create another file in your `attributes` directory called `attributes.yml.erb` (same name as your `attributes.yml` just with `erb` at the end.

Now go and figure out which environment variable to use for the database password. Mine was something like `<%= ENV['Password'] %>`. 

So copy what was in your `attributes.yml` and paste it into your `attributes.yml.erb`. Then change your hardcoded password to be your environment variable password.

```
password : <%= ENV['Password'] %>
```

# Create a rakefile

Now that you have your template (`erb`), you need to generate the desired file (`attributes.yml`). Create another file in your InSpec profile called `rakefile.rb`. Inside that, we're going to tell it what to create.

```ruby

require 'erb'

task :default => :generate

task :generate do
  Dir.glob('./attributes/*.yml.erb') do |rb_file|
    template = ERB.new File.new(rb_file).read, nil, '%'
    File.open(rb_file.chomp('.erb'), 'w') do |f|
      f.write template.result(binding)
    end
  end
end

```

As you can see, this file is going to generate another file out of all of the `.yml.erb` files in the `attributes` directory (we just have the one for now). So first, let's make sure our `rake` works. First, delete your `attributes.yml` (you can copy and paste its contents somewhere else to be safe).

Now go to your command line inside your profile's directory and run `rake`. Did it create your `attributes.yml`?! Great! If not, go troubleshoot.

# Test it out in TeamCity
So I won't give you a tutorial in TeamCity, but I needed to test it out there, so I ran my same `inspec exec` command inside a development enviroment build configuartion in TeamCity to see if the environment variables worked there. I did have to tweak it a bit to work within that pipeline but not a big deal.

First, of course, I had set another build step to do the rake.

Hoping for a successful build for you!! 

# Concluding Thoughts
It worked brilliantly until I realized that the cookbook I was testing was creating several different types of VMs with different roles and that I needed a way to test all of them separately. Originally, I thought that the cookbook was creating some sort of master node that I could log into the other nodes from and test them through that. Now I know that 1) that's a bad idea because you should use InSpec to access each node directly, and 2) that's probably not even possible. Live and learn.

The other very valuable lesson I learned is that it's not a waste of time to do everything manually first. It saves a ton of time and gains you better insight into what you actually need to code.