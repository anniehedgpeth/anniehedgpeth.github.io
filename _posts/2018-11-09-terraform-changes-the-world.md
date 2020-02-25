---
layout: post
title:  "Terraform Changes The World"
date:   2018-11-09 09:00:00
categories: devops, terraform, iac, hashiconf, hashicorp, actblue, how terraform will impact the 2018 us elections
tags: devops, terraform, iac, hashiconf, hashicorp, actblue, how terraform will impact the 2018 us elections
image: /assets/article_images/2018-11-09-terraform-changes-the-world/2018-11-09-terraform-changes-the-world.jpg
image2: /assets/article_images/2018-11-09-terraform-changes-the-world/2018-11-09-terraform-changes-the-world-mobile.jpg
---
We've all been subject to the scare-mongering around how technology will "take-over" and AI robots are going to kill us all and whatever. Really, though, we all know that technology is neutral, not inherently good or evil. So I really love a good story about how someone harnessed technology for positive change for humanity. Regardless of your political stance, I think you can appreciate how the story I'll relay to you impacts the world.

I went to my first HashiConf this year, and I really enjoyed it. I want to give you a recap of my favorite talk called ["How Terraform Will Impact the 2018 US Elections"](https://www.hashiconf.com/schedule#nicholas-klick-dan-catlin).

> In mid 2017, ActBlue began using Terraform to revamp its donation platform, a system which has accepted and processed over $2 Billion for political campaigns and nonprofits on the progressive left. The process began by leveraging Terraform to migrate a PCI compliant credit card vault to AWS and quickly expanded to support orchestration of the majority of the infrastructure, including non-PCI environments and a Fastly configuration. The agility, modularity, and transparency of Terraform has afforded the ActBlue DevOps team the ability to deliver more features and more responsiveness to our platform during a period of massive growth of Democratic donors, campaigns, and initiatives. This talk will cover the deep technical details of how we use Terraform, as well as how we have promoted and evangelized Terraform across technical teams. (from the HashiConf schedule)

As opposed to some of the more super intense, deep-dive technical talks, this was more simple in approach, and the speakers, Nicholas Klick and Dan Catlin, owned that but were thorough in explaining the benefits of using Terraform. The striking thing to me was how their simple approach to harnessing all that Terraform has to offer could literally change the world. You may know that [I really love Terraform](http://www.anniehedgie.com/terraform-and-azure), so I was already interested in whatever they had to say. They hit all the basics, and nothing was really _surprising_ because I agreed with all of it. The thing that made this talk so magnificently profound to me was the impact on our world that they give a healthy amount of credit to Terraform.

They noted the benefits of Terraform, for which we can all agree:

1. Infrastructure as Code (IaC)
1. Avoids drift
1. Opening black boxes
1. Lowers the barrier of entry for developers
1. Review changes
1. Reduces time to understand change
1. Enables dev and ops collaboration

<img src='/assets/article_images/2018-11-09-terraform-changes-the-world/terraform.jpg' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

Beyond that, the modularity was a huge plus for them.

1. Terraform modules
1. Account segmentation
1. Works across providers
1. Code reuse
1. Common configuration - single language for many providers
1. DRY (Don't Repeat Yourself) Code
1. Variations on common themes

They found they could be very agile in their approach to developing their IaC strategy because of the "emergent benefit of transparency and modularity" and an increasing developer engagement, leading to a rapid rate in which they could develop, scale, and respond.

They found that they could scale and move quickly because of the simplicity and agility that Terraform provided for them. Their company, [ActBlue](https://secure.actblue.com/), is empowering underrepresented candidates and taking super-PAC's money out of the equation by leveling the playing field and allowing money to flow to the people's candidates, like Beto O'Rourke. And sure, he didn't win, but no one can argue the impact on this election that he had and how we will likely see more of him, largely in part to the role that ActBlue played in his candidacy.

# Decision and Concluding Thoughts
*Never underestimate simplicity.* Great designs that can change the world are built upon simple, strong foundations.
