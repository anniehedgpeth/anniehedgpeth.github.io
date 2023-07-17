---
layout: post
title:  "A Chef Custom Resource"
date:   2017-02-10 06:00:00
categories: devops training, chef, custom resource, cookbooks, recipe, Learning, kata
tags: devops training, chef, custom resource, cookbooks, recipe, Learning, kata
image: /assets/article_images/2017-02-10-chef-custom-resource/chef-custom-resource.JPG
image2: /assets/article_images/2017-02-10-chef-custom-resource/chef-custom-resource-mobile.jpg
redirect_to: https://hedge-ops.com/chef-custom-resource
---
I have been working toward my Chef certification here lately, and my husband came up with this really cool [kata](https://github.com/mhedgpeth/chef-by-example) that I've been working on lately to study up for my first exam. A kata is something that you do over and over for training and for the purpose of bringing the broken parts of the process to light. It's origins are in karate, and I'm sure you've heard of how it was implemented at Toyota with their famous Toyota-kata. 

I really love this kata that Michael created because I can:

1. copy and paste the tasks into my [Checkvist](https://checkvist.com/),
2. create a [base cookbook](https://github.com/anniehedgpeth/chefkata), 
3. create a branch, 
4. run through the kata, knocking out each task on my Checkvist as I go, 
5. and then create another branch off of the base cookbook the next time I go through the kata.

It's been really good for me. It causes the things that I just don't understand to really stand out so that I can focus on them a little more. So one of those things that kept getting me stuck was [custom resources](https://docs.chef.io/custom_resources.html). For me, the documentation just wasn't enough. So I'm going to explicitly explain this one custom resource that I had to make so that I can come back to this and remember. Maybe it'll help some of you, too!

# Why I wasn't getting it

Here's what the Chef docs say:

[<img src='/assets/article_images/2017-02-10-chef-custom-resource/chefdocs.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />](https://docs.chef.io/custom_resources.html)

Honestly, when it all came down to it, I realized that I didn't understand the documentation because I didn't know the proper names for all of the parts of the resource. My understanding now of a very basic resource declaration is this:

```ruby
resource 'name' do  
  property value
  action :value
end
```

`resource` is the type of the resource.
`name` is the name of the resource. This can also be the value of a property if you don't assign one.
`property` is any word that you give to the property for use in the resource and not in quotes so that you can use it as a variable. 
`action` is a property of the resource that tells chef-client what to do.
`value` is the value that you're giving to `property`.

# My Recipe's Starting Point

Some of the tasks in the [kata](hhttps://github.com/mhedgpeth/chef-by-example) are:
 - Run the command `echo ran command > /var/website/command.txt`
 - Don't run the command the second time Chef converges (i.e. make it idempotent)
 - If the command does run, do a `git pull` of the architect repository into `/var/website/architect` (https://github.com/pages-themes/architect). It shouldn't pull the repository every time.
 - Refactor your command and pull into a custom resource called `chef_training_website`.

Okay, so those first three tasks leave me with these two resources (note: I did change the repo that he gave as an example):

```ruby
execute 'ran' do
  command 'echo ran command > /var/website/command.txt'
  not_if { ::File.exist?('/var/website/command.txt') }
end

git 'chefkata' do
  destination '/var/website/chefkata'
  repository 'https://github.com/mhedgpeth/chef-by-example.git'
  action :nothing
  subscribes :sync, 'execute[ran]', :immediately
end
```

There are a couple of reasons we'd want to make a custom resource. 
1. So that we can simplify the recipe for better readability
2. So that we can call this resource in a simple manner elsewhere in the cookbook, possibly with variables in it which change it 

So how do I make that whole block (above) into one custom resource? First, I'm going to show you what I ended up with, and then I'm going to show you what each thing means.

## My Custom Resource

Sibling to my `recipes` directory, I created a `resources` directory. Within that, I created a Ruby file that was just for that one custom resource that I wanted to create. I called it `chefkata.rb`, and put this in it.

```ruby
resource_name :chefkata 
property :kata, String, name_property: true

action :create do
  execute 'ran' do
    command 'echo ran command > /var/website/command.txt'
    not_if { ::File.exist?('/var/website/command.txt') }
  end

  git 'chefkata' do
    destination '/var/website/chefkata'
    repository kata_repo
    action :nothing
    subscribes :sync, 'execute[ran]', :immediately
  end
end
```
`chefkata` is the name of the resource that I called in my recipe after this was created.

`kata_repo` is the property, which is just like what `command` is in the execute resource (`execute` being the resource_name). 

`name_property` is the thing that you put in quotes after the `resource_name`. It's marked as `true` so that you can call the resource without the `name_property` (in this case `kata_repo`).

For example, these two resource calls are the same:

```ruby
directory 'website' do
  path '/var/website'
end
```

AND...

```ruby
directory '/var/website'
```

By omitting the `path`, which is the `name_property` for the `directory` resource, Chef will set the `path` property to `/var/website` because that's what I set the `name` to. So really, each resource has a different default `name_property` that you can find in docs.chef.io. 

## In the recipe

After that was finished, I was able to then call that resource in my recipe, which looked simply like this:

```ruby
chefkata 'https://github.com/mhedgpeth/chef-by-example.git'
```

As you can see, I substituted the `name` for the `kata_repo``property`. I could have also written it like this:

```ruby
chefkata 'example' do
  kata_repo 'https://github.com/mhedgpeth/chef-by-example.git'
end
```

# Concluding Thoughts

I have to admit that the way resources are created doesn't feel all that intuitive to me just yet. It could very well be that I just haven't used Chef enough for it to be intuitive yet; that's what [Michael](http://hedge-ops.com) says, anyway. But that's what this kata is for - to practice over and over until it is ingrained. 