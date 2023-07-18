---
layout: redirect
title:  "My New Friend, Cinc-Auditor"
date:   2021-04-09 12:00:00
categories: inspec, cinc-auditor, integration testing, chef, cicd, packer, image, pipeline, bundler, package cloud, rubygems
tags: inspec, cinc-auditor, integration testing, chef, cicd, packer, image, pipeline, bundler, package cloud, rubygems
image: /assets/article_images/2021-04-09-my-new-friend-cinc-auditor/cinc.jpg
image2: /assets/article_images/2021-04-09-my-new-friend-cinc-auditor/cinc-mobile.jpg
redirect: https://hedge-ops.com/my-new-friend-cinc-auditor
---
So I'm making a CI/CD pipeline to create a simple base image to use (the image is not relevant to the story, just so you know), and I want to validate the configuration scripts before I build the image, right? I mean, y'all know I love some [test driven development that I turn into integration tests](http://www.anniehedgie.com/red-green-refactor). And y'all know I love seeing passing green checkmarks. It's like my favorite thing.

And because I don't have the need for a Chef license, as I only need to run this for locally for my CI/CD process, I just need a little, light-weight tool to run my validation tests. That's where [InSpec](https://community.chef.io/tools/chef-inspec/) used to come in handy, but now you need to accept a license agreement to run InSpec, and I'm not a fan of going down that path, but what do I do? I freaking love InSpec, [y'all know that](http://www.anniehedgie.com/inspec/). 

Meet my new friend, [`cinc-auditor`](https://cinc.sh/start/auditor/). Now, it's been out for a while, but, because I was at a place with a Chef license, I had no use for it until now (save for a proof of concept I did a while back). 

As they state on their [website](https://cinc.sh/about/):
> Cinc is a recursive acronym for CINC Is Not Chef

> The Cinc project is in no way formally affiliated or associated with Chef Software Inc.

> Is Cinc compatible with upstream products ?
> Yes, it’s the same code as the original products, only branding is changed.

And no license is needed, so it's just what I need. So right now I have an integration testing pipeline that basically does this:

```bash
# build a docker image from a script of base image config (Dockerfile runs a bash sript)
$ docker build -t baseimage:test . 

# run the image with all the config on it
$ docker run -d -i --name baseimage baseimage:test 

# run InSpec, no wait, cinc-auditor against the image/container I just built
$ bunde exec cinc-auditor exec ./test/integration/my_config -t docker://baseimage 

# make sure the packer config is valid
$ packer validate ./Packerfile.pkr.hcl 
```

And I _had_ a simple `Gemfile` that looked like this:

```ruby
# spoiler alert - this Gemfile didn't work
source 'https://rubygems.org'

ruby '2.6.6'

gem 'rake'

source "https://packagecloud.io/cinc-project/stable" do
  gem "cinc-auditor-bin"
end
```

You can see there that `cinc-auditor` is pulled from the [Package Cloud](https://packagecloud.io)  manager, not [RubyGems](https://rubygems.org), so we grab have `bundler` it from there. But I was having an annoying issue where `bundler` couldn't find the `chef-utils` gem (a dependency of the `cinc-auditor` gem) in the RubyGems hosting server, and it was telling me:

```
Could not find chef-config-16.12.3 in any of the sources
```

And I knew it was a lie! I was so bothered! I could see it [_RIGHT THERE_](https://rubygems.org/gems/chef-utils)! So what gives?

So then I found the answer [here](https://packagecloud.io/cinc-project/stable/install#bundler) in the comments.

> Note: It's recommended you add the official https://rubygems.org source, unless your packagecloud repository can meet all of the dependency requirements in the Gemfile.

Okay, admittedly that doesn't really tell me anything I didn't already know, but it caused me to assume that **Cinc wants you to pull all of the dependencies that it can from the PackageCloud manager, not RubyGems**. So I changed my `Gemfile` to look like this, and voila, it worked. I was able to pull in all the dependencies. 

```ruby
ruby '2.6.6'

source 'https://rubygems.org' do
  gem 'rake'
end

source 'https://packagecloud.io/cinc-project/stable' do
  gem 'chef-config'
  gem 'chef-utils'
  gem 'cinc-auditor-bin'
  gem 'inspec'
  gem 'inspec-core'
end
```

**TL;DR: The other gems being pulled from Package Cloud are all dependencies of `cinc-auditor-bin`, so we pull them from PackageCloud and not RubyGems.**

_Hope this helps!_