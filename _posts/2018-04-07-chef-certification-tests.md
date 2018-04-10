---
layout: post
title:  "Chef Certification Tests"
date:   2018-04-07 09:00:00
categories: chef, certification, badges
tags: chef, certification, badges
image: /assets/article_images/2018-04-07-certified-chef-developer/certified-chef-developer.jpg
image2: /assets/article_images/2018-04-07-certified-chef-developer/certified-chef-developer-mobile.jpg
---
Last week I finished the last of the three required tests to become a _Certified Chef Developer_ (and passed - woohoo!). I took it kind of slowly, and just made it a quarterly objective to either study for or take a test over the past six months. It was a great experience, and I know that the tests are a bit mysterious, so I wanted to try and demystify it for you. (Their [FAQs](https://training.chef.io/certification-faq) are also helpful.)

![](/assets/article_images/2018-04-07-certified-chef-developer/ChefCertification.png) 

My understanding of the badges is that you need three to get certified. The two required badges are _Basic Chef Fluency_ and _Local Cookbook_Development, and then you have a choice between _Extending Chef_ and _Deploying Cookbooks_. The InSpec badge is the wildcard. I don't know that they have a plan for that one yet, which is why I haven't taken it. I will after they more clearly define it.

Back when I took this test I [told you](http://www.anniehedgie.com/basic-chef-fluency) that I had created a Github [repo](https://github.com/anniehedgpeth/chef-certification-study-guides) to house my study materials. I continued to add to it as I studied for the exams. 

I found it really useful to go through the the PDFs that they created with the lists of topics that would be covered in the exams and just write out as much info as I could about that topic. Searching through docs.chef.io was the best bet for these topics, not only because that's considered the source of truth, but also because it familiarizes you with where to find everything in the docs. This is particularly useful in the exam when you are allowed access to docs.chef.io and need to use your time wisely.

![](/assets/article_images/2018-04-07-certified-chef-developer/paths.png) 

# The badges I got
1. [Basic Chef Fluency](#basic-chef-fluency)
2. [Local Cookbook Development](#local-cookbook-development)
3. [Deploying Cookbooks](deploying-cookbooks)

Now, Chef has some really good study materials. I don't know why, though, but they just didn't jive for me for whatever reason. I would start on a [Chef Rally](https://learn.chef.io) lesson and then never finish. I think maybe for me they get a little too detailed with stuff that doesn't matter really, and I get confused, then discouraged, then distracted. What does work for me is starting at a super elementary level and working my way up. [Chef Rally](https://learn.chef.io) does work for a lot of people, though, so give it a go and see if you get lucky.

Otherwise, I'll share below what I did to prepare for each exam. Before I do that, I'll share some notes about the exam experience that pertain to all three exams.

# Notes about my Exam experience
 - There was not a visible timer, so you have to chat with the proctor to ask how much time is left, which wastes time.
 
 - If your internet connection is interrupted (mine was 6 times for one exam), they will give you the lost time, however, this is not ideal, because it makes you frantic and you can't go to the bathroom (it's a problem).
 
 - You may not use the restroom or else you forfeit the remainder of your time (don't ask how I know).
 
 - The setup may take a while since they have to scan your room and workspace, so plan accordingly.
 
 - The language of the questions is unnecessarily complicated. I had to reread some of them over and over only to find out it was a simple question with very confusing wording (exacerbated by nervousness).

![](/assets/article_images/2018-04-07-certified-chef-developer/badge-basic-chef-fluency.png) 
# [BASIC CHEF FLUENCY](https://training.chef.io/static/Basic_Chef_Fluency_Badge_Scope.pdf)
There are two basic components: a study sheet (cheat sheet) and a lab (kata).

### [Basic Chef Fluency Study Guide](https://github.com/anniehedgpeth/chef-certification-study-guides/tree/master/basic-chef-fluency) 
When studying for the [Basic Chef Fluency Badge exam](https://training.chef.io/basic-chef-fluency-badge), I studied this [guide](https://github.com/anniehedgpeth/chef-certification-study-guides/tree/master/basic-chef-fluency) daily until I was very comfortable going through the material.

### [Basic Chef Fluency Kata](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata.md)
This is an [exercise guide](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata.md) meant for daily use. At the time that I was studying for this exam, I was not using Chef in my daily practice, so I was a little rusty. Doing this kata, I was able to get comfortable with Chef enough for navigating the topics of the exam.

The idea is not to do the entire kata but to give yourself an allotted amount of time and start from the beginning each day. As you do this daily, you'll get further and further each day because you'll get faster and faster as you make those connections in your brain.

### [Basic Chef Fluency Kata Cheat Sheet](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata-cheatsheet.md)
As I was going through the kata daily, I would make reminders of what I did to solve the problem. That helped me to solidify it in my head and also gave me a quick reminder when I needed it. 

#### [Certified Chef Developer Basic Chef Fluency Badge by Linux Academy](https://linuxacademy.com/devops/training/course/name/certified-chef-developer-basic-chef-fluency-badge)
I have not taken this class, but I hear it is very good for preparing you for the exam.

![](/assets/article_images/2018-04-07-certified-chef-developer/badge-local-cookbook-development.png)
# [LOCAL COOKBOOK DEVELOPMENT](https://training.chef.io/static/Local_Cookbook_Development_Badge_Scope.pdf)
You can expect this 2 part exam to be tougher than the Basic Chef Fluency badge. It will be heavily focused on Test Kitchen, InSpec, and just basically creating cookbooks. So if you have healthy test-driven development practices with your cookbook development, then you will likely do just fine. If you don't, then this test will expose that. And guess what, I have another [study guide](https://github.com/anniehedgpeth/chef-certification-study-guides/tree/master/local-cookbook-development)!

### [Local Cookbook Development Study Guide](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/local-cookbook-development/local-cookbook-development-study-guide.md).
The study guide is just like with the Basic Fluency badge. Study them daily and have someone quiz you.

### [KATA](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata.md) 
If you'll notice for this badge, I don't have a new kata. That's because we just kept adding more to the [Basic Chef Fluency kata](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata.md) so that it really covers all three badges. If you want, instead of starting at the beginning, you can pick up at [Chef Server](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata.md#chef-server) section and see how far you get daily (remember, this is meant to start from the beginning daily, as opposed to picking up where you left off daily).

### Local Cookbook Development - Notes from Exam's Lab
You have a choice for whether you want to take this on Windows or Linux. The first time I took this on Windows and failed. I was really shaky with:

 - How to install 'IIS-WebServerRole' Windows Feature

 - How to install Windows Registry Keys (recursive true)

 - How to create a file with content and create the recursive directories

The second time I took it on Linux and breezed through it.

The Windows lab will require that you make 10 InSpec tests pass with the recipe. The requirements are very Windows specific (see above for examples).

![](/assets/article_images/2018-04-07-certified-chef-developer/DeployingCookbooks.png)
# [DEPLOYING COOKBOOKS](https://training.chef.io/static/Deploying_Cookbooks.pdf)
You can expect this 2 part exam to be tougher than the first two badges. This particular badge provides an alternative path to becoming _Certified Chef Developer_. The alternative is taking the _Extending Chef_ exam, which is focused a lot on extending Chef's capabilities, so creating OHAI plugins, custom resources, that type of stuff. Whereas, _Deploying Cookbooks_ is focused primarily on what you do with the cookbook after it's created, such as `knife` stuff, Chef server stuff, environments, roles, etc. If you already have _Basic Chef Fluency_ and _Local Cookbook Development_ badges, then if you pass this badge you will become Certified. Yay!

### [Deploying Cookbooks Study Guide](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/deploying-cookbooks/deploying-cookbooks-study-guide.md)
This is the [guide](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/deploying-cookbooks/deploying-cookbooks-study-guide.md) for this exam. As you can see, there are a few topics that are not filled in, and those are the topics I probably got wrong. (Feel free to create a pull request to add any info!)

### [KATA](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata.md) 
If you're rusty, I suggest going through the [kata](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata.md) and starting at the [Chef Server](https://github.com/anniehedgpeth/chef-certification-study-guides/blob/master/basic-chef-fluency/basic-chef-fluency-kata.md#chef-server) section and seeing how far you get daily. 

### Notes from Deploying Cookbooks Exam

1. Not being able to use dual-screens was a nuisance during the lab.

2. The first like 7 or so questions were nothing I encounter on a regular basis - lots of chef-solo. I had no clue. It felt like a disproportionate amount of questions, not a reflection of real-life use cases (to me, at least).

3. Using docs.chef.io was super awesome - much like real life. 

4. It was not clear to me that I could click on the link to go directly to the chef server UI. I thought I had to configure the connection to chef server manually via the command line, which I’ve never done, so I spent a ton of time messing with that before I realized that I could go into the UI. 

5. The lab was great once I figured that out. It was common, everyday stuff that everyone should know. If I had it my way, I 
would have done more of those questions and less of the first 10 multiple choice, which I feel like weren’t a reflection of my overall knowledge of Chef. 

# "But I'm just not good at taking tests"
That was me. I've never been good at multiple choice tests because I take too long second-guessing myself. Essay exams were always a breeze for me because I could explain what I knew, but I always felt multiple choice exams were always too harsh. Well,  my very wise husband suggested that perhaps I wasn't good at taking tests because I had never properly learned how to take a test, that perhaps I could create a game-plan for the test and see if I improved. Well, I did, and boy was he right. My anxiety went down, and I passed! Here's what I did:

1) Opened up Atom and created a blank file to write notes.
2) Started the questions and went through the first 40 pacing myself at about 60 seconds per question (it's a 90 minute exam).
   - Any time I got to a question I wasn't super certain of, I'd type the question number in the blank Atom file to come back to it later.
   - If I knew exactly where the answer was in docs.chef.io and I knew I could find it quickly, then I would, but if it required digging, I typed the question number in Atom.
3) After the first pass at the multiple choice questions, I started and finished the lab.
4) Then I returned to my Atom file and began looking up all of the questions in docs.chef.io and answering them.
