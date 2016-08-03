---
layout: post
title:  "InSpec Basics: Day 8 - InSpec and Me"
date:   2016-07-02 03:00:00
categories: chef, chef compliance, inspec, security, inspec tutorial, devsecops, devsecops, devops
tags: chef, chef compliance, inspec, security, tutorial, inspec tutorial, devsecops, devsecops, devops
image: /assets/article_images/2016-07-02-inspec-basics-8/inspec-basics-8.jpg
image2: /assets/article_images/2016-07-02-inspec-basics-8/inspec-basics-8-mobile.jpg
---
Hello my friends. If you've noticed that I've slowed down on the [InSpec](https://github.com/chef/inspec) goodness lately, it's because I've been [learning Ruby](http://www.anniehedgie.com/learning-ruby) and [experimenting](https://github.com/chef/chef/pull/5066) with [fixing bugs](https://github.com/chef/inspec/pull/810) and whatnot. It's really exciting to see what I can do with Chef and InSpec once I get a good grasp on Ruby, but I underestimated the learning curve just a little. No worries, no hurries! 

 Check out all we've covered so far:

  - Day 1: [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - Day 2: [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - Day 3: [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - Day 4: [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - Day 5: [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - Day 6: [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
  - Day 7: [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)

All of this [talking about InSpec](http://www.anniehedgie.com/inspec-basics-1) has had me thinking about things, like: 

  - [How InSpec bridges the divide between Security and DevOps](#bridging-the-divide-between-security-and-devops)
  - [How I can see a certain role forming within Security teams that wasn't there before](#the-role-that-wasnt-there-before)
  - [How I'd like to fill that role](#how-id-like-to-fill-that-role)

# Bridging the divide between Security and Devops  
For those organizations whose software security initiatives (SSI) employ security automation into the software lifecycle from inception to deployment to maintenance, then InSpec is perfect, right? Of course. (Let's not forget you can use InSpec with Puppet, too.) You want your Software Security Group (SSG) to be structured properly and everyone fully invested.

<img src='/assets/article_images/2016-07-02-inspec-basics-8/SSG.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

But let's remember one of the many reasons why [The Phoenix Project](https://www.amazon.com/dp/B00AZRBLHO/ref=dp-kindle-redirect?_encoding=UTF8&btkr=1#navbar) hit home with so many people - the strained relationship, lack of trust, and back-biting between security and development. It's a real thing, hopefully not in your company, but probably. 

You know the story - the good folks in Security & Compliance want to ensure compliance so they have PDF after PDF documenting what they need for said compliance. There is then built into their culture a mistrust of outsiders because of their audit function; their process mustn't be corrupted. 

Development, on the other hand, wants to get their software shipped as quickly as possible, so they look at the PDFs and say, "Yeah, yeah, of course, we'll get to that." But, of course, their need for speed is greater than their desire for compliance because they don't have a full picture of the requirements and their company's need for them. And so ensues the stereotypical strained security-development relationship.

The problem lies in that the two groups are speaking different languages. Security speaks PDF, and Development speaks code. So how do we translate for these two groups? (I think you see what's coming here.) Ahem...InSpec does a great job at this. But how can your DevOps people convince your Security people that this is the way to go?

As I've seen it played out, this is not as easy as it may seem. It takes a bit of *finesse*. These two groups in your company may have been at odds for so long that it requires dipolomatic and empathetic soft skills on the part of the DevOps person managing this affair - someone who can convince the rest of Development that security matters and that it's not mitutia and who can convince Security that automation will make everyone's lives so much easier and enable them to focus on the higher level issues instead of staying in the weeds all the time. An openness to change and learn is necessary for all involved, from the top down.

Once the most empathetic DevOps person convinces Security to give it a go, they can use the magic of [Chef Compliance](http://www.anniehedgie.com/tour-of-chef-compliance) to most likely get them to about 80% compliant with their corporate security initiatives using the built-in profiles to scan against. This will give all people involved a greater sense of their current state of affairs, and Development can start remediating the heck out of things instead of spending all their time confused about what the security risks are. I can pretty much promise that this will get people excited, and things will start rolling with DevOps and Security working with each other instead of against each other.

# The role that wasn't there before
Because each organization is unique and has their own security policies, we'll probably still have around 20% of compliance issues with which to contend. This is where, in my opinion, someone will need to swoop in. This person will need to create custom resources and profiles specific to their company's policies and incorporate that job into the audit function within their security department. The way I see it, though, this is not your typical security person. This person will still need to research the latest and greatest security issues, but instead of putting them into a PDF, she'll be putting them in code.

*"Wait, what?! A developer on the security team?!"* 

Well, why not? This person would still need to understand security at a deep level, but their main objective would be to understand the language of both worlds and bring them together. DevOps would serve a support function, but since Security would still need to be in control of the audit process, this person would bring the necessary additional skillset for automation and how to drive it.

Because this gives Security the ability to focus on higher level security matters, the cost of hiring on another person to fill this role is a no-brainer to me. It totally takes their company to the next level of security and compliance. 

# How I'd like to fill that role
I am, of course, a little biased because, if you couldn't tell by now, I'd love to be that person.

Now I didn't come to that conclusion overnight. I have [stressed and stressed](http://www.anniehedgie.com/introduction) over how I can be used to my fullest potential. I have all these soft skills, creativity, and overwhelming need to problem-solve that weren't being fully utilized in my my other career paths. So I feel so very grateful to the InSpec team because they really lowered the barrier to entry into technology for me, so now I can now use my strengths in a field in which I'll have more diverse thinking to bring to the table, having *not* spent the last twenty years immersed in technology.

Being new to the DevOps and open-source community, I find it so very refreshing and inviting. Remember me saying that I was an [Airbnb superhost](http://www.anniehedgie.com/red-green-refactor)? Well, I *love* the sharing economy. It truly gives me hope for my kids' futures. And that same heart is what I've found in the DevOps and open-source community. I feel like you (said community) really *get* that there is talent out there waiting to be unleashed, and you're doing everything in your power to welcome noobs like me into the fold so that potential can be realized. 

In addition to InSpec, I'm grateful to [GitHub](https://github.com/) for being the other great factor in lowering the barrier to entry for me. [Michael](http://hedge-ops.com)'s [company](http://www.ncr.com) is going through this transformation that I was portraying above, and so, being the good DevOps/Security liaison, we hosted a dinner at our house with his security colleagues, his boss, a lovely VP at Chef, and the two authors of InSpec, [Christoph Hartmann](https://twitter.com/chri_hartmann) and [Dominik Richter](https://twitter.com/arlimus). Honestly, they talked and I listened and observed. Then afterward Michael and I talked some more about the cultural dilemma that exists between Security and DevOps, and I wanted to *fix it!*

It's such an interesting and complicated problem, and it's seriously calling my name to come and solve it. But had it not been for GitHub, that dinner conversation would have ended there, no more story. Instead, I was able to start learning InSpec and even give back by writing about it on this blog which is hosted by [GitHub Pages](https://pages.github.com/). I could also interact with Chef and InSpec friends on GitHub and then deepen my understanding by trying to fix bugs. As someone who is new to the industry, this is incredibly helpful because I can point prospective employers to [my GitHub page](https://github.com/anniehedgpeth) instead of handing them a one page document of my past experience. These opportunities would not have existed before GitHub.

And so, my story continues, and we'll see where it goes from here. I'd be very interested to see if my predictions come to pass in the industry as this need for the DevOpsSec position grows as the need for security automation grows. And we'll see where I end up. I'll definitely be solving some problems *somewhere*, just don't know *where* yet. 

P.S. Thank you to all my Twitter friends who retweeted that [I'm on the prowl](https://twitter.com/anniehedgie/status/748643963431587840) for a job in Chef/InSpec/Security! Feeling the love. 

P.S.S. I'll be at [ChefConf](https://chefconf2016.eventcore.com/) next week, so give me a shoutout if you'll be there!

Go to Day 9: [Regular Expressions](http://www.anniehedgie.com/inspec-basics-9)