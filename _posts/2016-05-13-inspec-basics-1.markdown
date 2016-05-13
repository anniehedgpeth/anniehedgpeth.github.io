---
layout: post
title:  "InSpec Tutorial: Day 1 - Hello World"
date:   2016-05-13 08:00:00
categories: chef, chef compliance, inspec, security
tags: chef, chef compliance, inspec, security, tutorial
image: /assets/article_images/2016-05-13-inspec-basics-1/inspec-basics-1.jpg
image2: /assets/article_images/2016-05-13-inspec-basics-1/inspec-basics-1-mobile.jpg
---
I've been sharing what I've learned about [Chef Compliance](http://www.anniehedgie.com/setting-up-compliance), and because it uses the [InSpec framework](https://www.chef.io/compliance/), I want to start a little series on [InSpec](https://www.chef.io/inspec/) to gain a fuller understanding, appreciation for, and greater flexibility with [Compliance](https://www.chef.io/compliance/). 

It's possible that you're part of a company, perhaps without a dedicated security team, that might be totally content to run scans off of the premade [CIS profiles](https://benchmarks.cisecurity.org/) and call it a day. In my opinion, that's when you're getting the biggest bang for your buck with Compliance. It couldn't be easier! 

But it's more likely that the built-in Compliance profiles will get you to 80% of what you need, and then you'll want to add or edit a bunch of other specific tests or maybe even take away some of the profile's tests to meet the other 20% of your needs. By the end of this series, I'll know how to do it (because I'm learning as I go), and you will, too!

Today, we're going to run through a really simple set up and run a *Hello World* test, just to get our feet wet. And don't forget, I'm going totally basic on you because I want non-developer-types to learn, too! That's actually the thing that attracted me [getting started in my tech journey](http://www.anniehedgie.com/introduction) with InSpec and Compliance - because it's totally approachable and the authors *want* it to be understandable by non-developer-types. 

By the end of this series, I suppose, I will have tested their intentions one way or another. And for full disclosure, Chef is not paying me for these posts, so you're getting a truly unbiased opinion. [My husband's](http://hedge-ops.com) [company](http://www.ncr.com) is a customer of Chef's which is what gave me the idea to delve into Compliance as a starting point.


## Installation
Okay, enough about me, let's open up some terminals and get started. If you're already have the updated versions of Homebrew, Ruby, and InSpec, then skip ahead!  

### Install Homebrew
So apparently, before I could install InSpec, I needed to have the latest version of Ruby installed. And before I could install the latest version of Ruby, I had to install [Homebrew](http://brew.sh/), the OS X package manager. 

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Update Ruby
Here's what I ran for the Ruby update:

```
brew install rbenv ruby-build

# Add rbenv to bash so that it loads every time you open a terminal

echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
source ~/.bash_profile

rbenv install 2.3.0
rbenv global 2.3.0
```

Close terminal and reopen

```
ruby -v
```

So now do you have the latest version of Ruby 2.3.0?? It'll say after you run that last command.

### Installing InSpec
Now we're on to the good stuff. Let's install InSpec:

```
gem install inspec
```

Just to be sure everything went according to plan, run `inspec`, and you should see something that looks like a command menu. So now we're all updated, and we're ready to get started.

## Hello World Tutorial
First, we're going to create a file with some text in it. Then we're going to make a test to look for *other* text in the file, setting ourselves up for failure. Then we'll add the correct text so that we can redeem ourselves. So here we go...
 
### Create a file to test
  - **Create a folder** and open it in your text editor. (I'm using Visual Studio Code.) 
  - In that folder, create a file called **hello.txt**. 
  - In that file, type the text "Goodnight Moon". (Don't forget to save - gets me every time.)
![](/assets/article_images/2016-05-13-inspec-basics-1/01-text-file.png)

### Create the test 
  - Create a file in that same folder called **hello_spec.rb**.  
  - In that file we're going to create a *control* with a [*file resource*](https://docs.chef.io/inspec_reference.html#file) having a [*content matcher*](https://docs.chef.io/inspec_reference.html#id42) 'Hello World!' in it. In other words, this file is going to check and see if the other file has any text in it that *matches* 'Hello World'. 
 
```ruby
control "world-1.0" do                                # A unique ID for this control
  impact 1.0                                          # Just how critical is
  title "Hello World"                                 # Readable by a human
  desc "Text should include the words 'hello world'." # Optional description
  describe file('hello.txt') do                       # The actual test
   its('content') { should match 'Hello World' }
  end
end
```

### The failed test 
  - Now go to that folder in your terminal, and let's run the command. 
  
  ```inspec exec hello_spec.rb```
  
  ![](/assets/article_images/2016-05-13-inspec-basics-1/02-failed.png)

  - Yay! We failed!

### Make up test
Okay, so you probably don't like failure any more than I do, so let's edit that text file so that we pass.

  - Add the text "Hello World!" to the **hello.txt** file.
  
![](/assets/article_images/2016-05-13-inspec-basics-1/03-hello-world.png)

  - Now let's go back to our terminal and rerun `inspec exec hello_spec.rb` and see what happens.
  
![](/assets/article_images/2016-05-13-inspec-basics-1/04-passed.png)

  - We passed! Yay! 
  
## Concluding Thoughts
Doing this little exercise helped me to get my mind around what Chef Compliance does at a very basic level. I really like how clear and concise the framework is. In later posts, however, I'll tell you where I've been tripped up and how I got around that. At its core, however, I think that it's within my grasp; I just need to study up on some more basics. 