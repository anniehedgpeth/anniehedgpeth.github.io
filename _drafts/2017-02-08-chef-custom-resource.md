---
layout: post
title:  "Chef Custom Resources"
date:   2017-02-08 12:00:00
categories: devops training, chef, custom resource, cookbooks, recipe, Learning
tags: devops training, chef, custom resource, cookbooks, recipe, Learning
image: /assets/article_images/2017-02-08-chef-custom-resources/chef-custom-resources.jpg
image2: /assets/article_images/2017-02-08-chef-custom-resources/chef-custom-resources-mobile.jpg
---
I have been working toward my Chef certification here lately, and my husband came up with this really cool [kata](hhttps://github.com/mhedgpeth/chef-by-example) that I've been working on lately to study up for my first exam. I love it because I can:

1) copy and paste of the tasks into my [Checkvist](https://checkvist.com/),
2) create a [base cookbook](https://github.com/anniehedgpeth/chefkata), 
3) create a branch, 
4) run through the kata, knocking out each task on my Checkvist as I go, 
5) and then create another branch off of the base cookbook the next time I go through the kata.

It's been really good for me. It also makes the things that I just don't understand really stand out so that I can focus on them a little more. So one of those things that kept getting me stuck was [custom resources](https://docs.chef.io/custom_resources.html). For me, the documentation just wasn't enough. So I'm going to explicitly explain it so that I can come back to this and remember. Maybe it'll help some of you, too!

#My Recipe's Starting Point
Some of the tasks in the kata are:
 - Run the command `echo ran command > /var/website/command.txt`
 - Don't run the command the second time chef converges (i.e. make it idempotent)
 - If the command does run, do a `git pull` of the architect repository into `/var/website/architect` (https://github.com/pages-themes/architect). It shouldn't pull the repository every time.
 - Refactor your command and pull into a custom resource called `chef_training_website`.

Okay, so those first three tasks leave me with these two resources:

```ruby
execute 'ran' do
  command 'echo ran command > /var/website/command.txt'
  not_if { ::File.exist?('/var/website/command.txt') }
end

git 'git-architect' do
  destination '/var/website/architect'
  repository 'https://github.com/pages-themes/architect'
  action :nothing
  subscribes :sync, 'execute[ran]', :immediately
end
```

So how do I make ^that^ whole block into one custom resource?

resource_name :git_website
# Property is a made up word for use in the resource and not in quotes so that you can use it in as variable. In this case, "git_repo" is equivalent to "command" in the execute resource. "name_property" is what is in quotes after the resource is called. If you don't put anything as the property, then it uses what's in the name_property.
property :git_repo, String, default: 'https://github.com/pages-themes/architect', name_property: true

action :create do
  execute 'ran' do
    command 'echo ran command > /var/website/command.txt'
    not_if { ::File.exist?('/var/website/command.txt') }
  end

  git 'git-architect' do
    destination '/var/website/architect'
    repository git_repo
    action :nothing
    subscribes :sync, 'execute[ran]', :immediately
  end
end
