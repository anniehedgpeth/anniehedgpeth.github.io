---
layout: post
title:  "How I Learned Red, Green, Refactor from Airbnb"
date:   2016-06-07 05:00:00
categories: red green refactor, devops, unit testing, airbnb
tags: testing
image: /assets/article_images/2016-06-07-red-green-refactor/red-green-refactor.jpg
image2: /assets/article_images/2016-05-29-momops/momops-mobile.jpg
---
<img src='/assets/article_images/2016-06-07-red-green-refactor/red-green-refactor.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

# Red
Two summers ago I had booked a place on Airbnb for a vacation, and in return Airbnb had asked if I wanted to rent out my place. I'll try anything once, so I did it. I figured that we could just book it once and use that money to go on a vacation. (And we did! We totally broke even on the deal, including gas, food, and entertainment.)

The one hiccup in the plan was that we couldn't check the guests in personally because we had to get on the road early to go on our vacation. So we were driving the 10 hours to Taos, NM, and as with any long roadtrip, you know that you experience several drops in phone signal, sometimes for quite a long time. 

I had lost my signal for probably an hour as we drove through the eastern portion New Mexico, and suddenly I get about 10 texts and voicemails all at once.

>"Hello Mrs. Hedgpeth, we're getting an alarm from your home. Since we can't reach you, we will dispatch police."


> "Hi Annie, this is Emily, your Airbnb guest. We got in and the alarm was on, but you didn't give us the code. Can you call me ASAP!" 


>"Annie, it's Courtney. Your guests set off your alarm. The police are here. What's your code? They can't turn it off."


>"Hi Annie, it's David from across the street. There are cops going into your house. I'll keep you updated."

I. Lost. It. It was a good thing I wasn't driving. I was so mad at myself. I *thought* I had thought of everything. Now I had to spend the rest of my day cleaning up the mess I had created. 

**I vowed to never rent my house out again.**

I told myself that I was just not cut out for it, that there's just too much to think of and too much that can go wrong. 

I was totally right about there being too much to think of. And there's a LOT that can go wrong. Unfortunately, I couldn't quit because I had already booked the house out two more times after that, and we had already planned on using that money for two other trips. I had no choice but to suck it up and figure it out. 

It was time to start making some lists. First, I made a list of everything that had gone wrong in that little scenario, and I made a plan to remediate it for next time. Then I made a list of everything that I had done in order to prepare, even down to the most miniscule of details.  

<img src='/assets/article_images/2016-06-07-red-green-refactor/airbnb.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

# Green
Now that I had the safety of my lists and processes, I was ready for our next booking. I was still a little afraid that I'd forget something, but my mindset had changed. Sure it would have been a big bummer if something else would have gone wrong, but it would just serve to give me more data that I could use to further improve upon my processes.

I'm happy to say that the next booking went off without a hitch. AND, in a very short time I had the coveted title of *Superhost*.
  
And I even exceeded the requirements!
<img src='/assets/article_images/2016-06-07-red-green-refactor/superhost.jpg' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

# Refactor
With each booking (I went on to do it for another year after that) I improved upon my system. There were little things that I had to add to the list here and there that only served to make the experience better for all involved. I even wrote a 25 page house manual with every detail you could ever hope to know about my house, from how to work the washer to where the nearest hospital is. 

# Workflow
So how does that translate into technology for me? Most of you devopsy, unit tester types already know all of this, but for me, it took a really frustrating two days at the coffee shop to be reminded of the importance of a good workflow.

<img src='/assets/article_images/2016-06-07-red-green-refactor/coffee-shop.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

We have been without internet at the house for a *week* (thanks for nothing, Frontier FiOS), so I've had to spend many long hours at the coffee shop like a vagrant. I know you know what it's like without a workflow, too. 

*You start on something..find an issue..it reminds you of another issue so you go to it..you forget about the first thing..you can't figure out the second thing so you go back to the first thing..you don't remember it so you have to retest..someone you know walks in so you say hi..you think you know how to solve that second problem now..your favorite song comes on and your mind wanders...and so on.*

So frustrating! But knowing is half the battle, so as I'm trying to write my control tests and remediate through kitchen, I have a simple plan that will keep me on the straight and narrow:

  - Converge
  - Verify
  - Fix control
  - Verify
  - Fix cookbook
  - Converge
  - Verify
  - Check In

# Concluding Thoughts
When things are all in a jumble and I'm confused and frustrated and mad, it's easy to tell myself some pretty self-defeating junk. But focus is so simple and so powerful. And in the past when I've really focused on things, like Airbnb, I've had great results. I know that the same will be true for my IT pursuits, and I'm excited to see what happens.