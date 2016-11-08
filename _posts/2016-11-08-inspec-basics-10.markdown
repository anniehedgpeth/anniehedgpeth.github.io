---
layout: post
title:  "InSpec Basics: Day 10 - Attributes with Environment Variables"
date:   2016-11-08 12:00:00
categories: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, attributes, envrionment variables, rake, rakefile
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, attributes, envrionment variables, rake, rakefile
image: /assets/article_images/2016-11-08-inspec-basics-10/inspec-basics-10.jpg
image2: /assets/article_images/2016-11-08-inspec-basics-10/inspec-basics-10-mobile.jpg
---
My last post about attributes was really born out of this issue I had had creating an InSpec profile that tests the build configuration of a machine within a pipeline in TeamCity and testing all of the different environments, making sure the correct Mysql passwords were entered in for each enviroment. In my last post, I had given you a crash course in how to use attributes,so now I'm going to show you how I used attributes to create the passwords that I needed using environment variables. 

But first, if you've missed out on any of my tutorials, you can find them here:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - Day 6: [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
  - Day 7: [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)
  - Day 8: [Regular Expressions](http://www.anniehedgie.com/inspec-basics-8)
  - Day 9: [Attributes](http://www.anniehedgie.com/inspec-basics-9)

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

So you see up there how the password calls an [attribute](http://www.anniehedgie.com/inspec-basics-9)? Well, eventually I would have to make an attributes yaml, but don't worry, before that I just hardcoded the value. So I made a directory in my profile called `attributes`. Then I created a file in there called `attributes.yml`. The yaml was very simple, like this:

```
password: HARDCODEDpasswordHERE
```

Scroll down to the bottom of [THIS](http://inspec.io/docs/reference/profiles/) page for more info on it. So I tested that out to see if it worked on my development environment. From my profile directory on the command line I ran:

```
inspec exec . -t ssh://USERNAME@DEVENV -i ~path/to/key/.ssh/id_rsa --attrs attributes/attributes.yml # OR --password=PASSWORD if not using a key
```

It worked; great! Let's keep moving!

# Make mysql password attribute configurable

So I still needed a different password for each environment that I ran this on, right? So this hardcoded yaml wasn't gonna cut it. I needed a different yaml for each environment. Enter the erb and rakefile. I created a template that builds this yaml each time for me. 

If you haven't used an `erb` before, it's basically a template that creates files for you. You have to run a `rake` command before you run your InSpec profile so that your desired file, in this case, our `attributes.yml`, is generated from the `erb`. 

First thing I did was to create another file in my `attributes` directory called `attributes.yml.erb` (same name as my `attributes.yml` just with `erb` at the end.)

Now to figure out which environment variable to use for the database password. It was something like `<%= ENV['Password'] %>`. 

So I copied what was in my `attributes.yml` and pasted it into my `attributes.yml.erb`. Then I changed the hardcoded password to be the environment variable password.

```
password : <%= ENV['Password'] %>
```

# Create a rakefile

Once I had my template (`erb`), I needed to generate the desired file (`attributes.yml`). So to do that, I had to create another file in my InSpec profile called `rakefile.rb`. That's the magic file that tells the `rake` command what to create.

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

As you can see, this file is going to generate another file out of all of the `.yml.erb` files in the `attributes` directory (at this point there was just one). So first, I made sure my `rake` works. I deleted the `attributes.yml` (copying and pasting its contents somewhere else to be safe is never a bad idea).

Then, from my command line inside my profile's directory, I ran `rake`. And guess what; it created my `attributes.yml`!

# Test it out in TeamCity
So I won't give you a tutorial in TeamCity, but I did need to test it out there, so I ran my same `inspec exec` command inside a development enviroment build configuartion in TeamCity to see if the environment variables worked there. I did have to tweak it a bit to work within that pipeline but not a big deal.

First, of course, I had set another build step to do the rake.

After all of that we decided to wrap it in Ruby code and run the rake and profile that way, but all in all, it was just fine!

# Concluding Thoughts
As I said in my last post, I learned that it is not a waste of time to do things manually first. It saves a ton of time and gains you better insight into what you actually need to code. 

Also, as far as my blog posts go, it looks like I'll be pivoting away from the straight tutorials and moving more toward "how I did it" type of posts. I was getting in the weeds about making it perfectly follow-able, but I got a lot of good feedback at the Chef Community Summit that it wasn't really all that necessary. So there you go! 