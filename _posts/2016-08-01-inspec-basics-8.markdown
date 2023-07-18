---
layout: redirect
title:  "InSpec Basics: Day 8 - Regular Expressions"
date:   2016-08-01 03:00:00
categories: chef, chef compliance, inspec, security, inspec tutorial, devsecops, devsecops, devops, regex, regular expressions, rubular
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops, regex, regular expressions, rubular
image: /assets/article_images/2016-08-01-inspec-basics-8/inspec-basics-8.jpg
image2: /assets/article_images/2016-08-01-inspec-basics-8/inspec-basics-8-mobile.jpg
redirect: https://hedge-ops.com/inspec-basics-8
---
So you know how when you're learning stuff and something comes across your radar that you don't get at all so you make a mental note to study it later? Well, I have many of those, but the one I'm going to talk about today concerns writing a test to search for regular expressions.

As a frame of reference and recap, here are the other InSpec posts that we've covered thus far:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - Day 6: [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
  - Day 7: [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)

The other day a kind githubber [pointed out to me](https://github.com/anniehedgpeth/inspec-workshop/issues/1) that way back in the post about writing a [file resource](http://www.anniehedgie.com/inspec-basics-3), perhaps I should have thought about creating a bit more of a strict search criteria when I was searching for a regex in a file. I totally agree with him; I just didn't know how back when I wrote the first one. 

The basic gist of the control was to search a yum.conf file for `gpgcheck=1`. Easy enough, right? Well, this is the whole control that I ended up with:

```ruby
control "cis-1-2-2" do
  impact 1.0
  title "1.2.2 Verify that gpgcheck is Globally Activated (Scored)"
  desc "The gpgcheck option, found in the main section of the /etc/yum.conf file determines if an RPM package's signature is always checked prior to its installation."
  describe file('/etc/yum.conf') do
    its('content') { should match /gpgcheck=1/ }
  end
end
```

Some of you know exactly what's wrong with that, and others of you are like I was - called it good. But let's ask some questions to find out where the holes are.

1. What if there are a bunch of spaces before, after, or in between that text? Does that matter?
2. What if there is any other text before or after that regex? For example `gpgcheck=12`, or it's commented out.

Well, thankfully [Mr. Lovitt](https://twitter.com/lovitt) at [Rubular](http://rubular.com/) gave us a little cheat sheet.

[<img src='/assets/article_images/2016-08-01-inspec-basics-8/regex.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />](http://rubular.com/)

So now, to address my questions above

1. If I want to allow for any amount of white space to precede and/or follow the text, I can add `\s*`. The `\s` means white spaces, and the `*` means any amount.
2. If I want to disallow for anything before or after my regex, then I can add `^` to specify the beginning of the line and `$` to specify the end of the line. I can also ignore anything commented out *after* my regex with `(#.*)`. We can also use the `?` after that because, according to [RegExr](http://regexr.com/), it "makes the preceding quantifier lazy, causing it to match as few characters as possible." 

Now I can use this guy, and it will be as strict as I need it to be so as not get a false pass on my test.

```
    its('content') { should match /^\s*fs.suid_dumpable = 0\s*(#.*)?$/ }
```

Obvi, just use the cheat sheet to find what's right for your search.


# But
Another thing that my githubber friend and I were discussing, however, is that perhaps searching for regexes are a bit too messy. First of all, they're ugly. Am I right? It took me quite a while just to figure out what it meant. And secondly, you put yourself at greater risk for false passed tests with all the gobbly-gook, and no one wants that. Therefore, if there's a better way to test, then do your best to find it.

In this case, it's possible that using the `parse_config` resource could be a better test but more on that another time! 

## Concluding Thoughts
There's usually a better way to do everything, but that shouldn't stop us from doing what we can to get started. I think that sometimes people get overwhelmed because they think they have to be at the [*refactored*](http://www.anniehedgie.com/red-green-refactor) state from the beginning, but that's not the ideal way to grow - whether you're learning InSpec or starting a business. We start small, manageable, and simple, and we grow and perfect from there, accepting our mistakes as learning tools. Also, refactoring, which takes time, effort, and discipline, can't be done without laying the simple groundwork first. And in the end, hopefully, you come up with something that is meaningful and lasting.

Go to Day 9: [Attributes](http://www.anniehedgie.com/inspec-basics-9)