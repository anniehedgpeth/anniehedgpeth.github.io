---
layout: post
title:  "My Devops Training Plan"
date:   2017-01-01 12:00:00
categories: devops training
tags: devops training
image: /assets/article_images/2017-01-01-devops-training-plan/plan.jpg
image2: /assets/article_images/2017-01-01-devops-training-plan/plan-mobile.png
---
Happy New Year, my friends! 

Despite the bad press that 2016 got, I actually had a pretty good year. It was arguably the year of the greatest risk, challenge, and also growth in my life. I'm so lucky to get to continue that growth at a company who not only supports that but encourages it.

So I thought as a way to kick off the new year, I would share with you the plan I have for continuing my growth in technology this coming year. I'm so super excited about it, and don't you know, I'll be tracking my learning here at the ol' blog. I will be comparing the different technologies and creating tutorials here and there. 

My projects will center around application deployment and the CI/CD pipeline that will support that. Honestly, it's been a bit of a blackbox for me up until now, so I'm so excited for it to all start coming together. I've learned most of these technologies solitarily but haven't had the opportunity to see the magic of it all being used together.

So here's the low-down of what I'll be spending every spare training moment for in the coming year.

## DEVELOPMENT
During my training these would be the everyday tools in my tool chest. Honestly, they have since I started, but I've been on projects lately where I have gotten out of daily practice, so I'm happy to get back into using them daily.

 - *[Git](https://github.com/anniehedgpeth)* - Will I ever stop getting nervous about branching?
 - *[Visual Studio Code](https://code.visualstudio.com/)* - I tried Atom, but I still like VSC better, maybe because it's what I'm used to.
 - *CLI* - I'd especially like to be more proficient at the Azure CLI.
 - *[Test Kitchen](http://kitchen.ci/)* - The other day I learned that not everyone uses Kitchen, and I felt sorry for those people.

## CONFIGURATION MANAGEMENT
While Chef is what I desire to focus on, I think it would be a great exercise to learn the basics of Ansible and DSC to be able to know the reasons I would choose one over the others. 

 - *[Chef](https://www.chef.io/)* - It's amazing how quickly one can forget things while not using them regularly! I'm hoping it's like riding a bike.
 - *[Ansible](https://www.ansible.com/)* - I've never used Ansible, so that will be fun to see what it has to offer.
 - *[DSC / Powershell](https://msdn.microsoft.com/en-us/powershell/dsc/overview)* - There's a consultant at my work that is a huge DSC fan, and he just learned Chef, so I'm planning on picking his brain when I get to this point.

## SECURITY
 - *[InSpec](https://www.inspec.io)* - I'm excited about seeing it in other contexts and gaining way more comfort and familiarity with it.
 - *[Hashicorp Vault](https://www.vaultproject.io/)* - I'm hoping to unlock the mystery of Vault. Right now it's a total enigma to me. 

## PIPELINE / CI/CD
I think learning all three of these would give me a good basis for comparison. And since I’ve already worked with TeamCity, I’m starting with Jenkins.
<img src='/assets/article_images/2017-01-01-devops-training-plan/jenkinspipeline.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

 - *[Jenkins](https://jenkins.io/)* - In the short time I've been learning Jenkins, it's way easier than TC, but that's possibly because my project is simpler. I'll be interested in the side-by-side comparison. 
 - *[Team City](https://jenkins.io/)* - I've only worked on one TC project in the past, so I'll be glad to get more experience with it.
 - *[Chef Workflow](https://docs.chef.io/workflow.html)* - This will be totally new to me, but I don't know of a ton of people that would choose it over Jenkins, so I want to know why.

## PROVISIONING
 - *[Terraform](https://www.terraform.io/)* - A lot of people I look up to use Terraform religiously, so it'll be interesting to see if my bias remains with Terraform after learning to provision with all three methods. 
 - *[ARM Templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates)* - I'm interested in learning when I would use this over Terraform.
 - *[Packer](https://www.packer.io/)* - I haven't worked with Packer at all, so this will be new, too.

## AZURE
This is a given since I'm working at an Azure shop, but I'm working on honing my Azure skills more as I use all of the above technologies to provision Azure. My focus, however, will be the following.

 - *[AD](https://www.microsoft.com/en-us/cloud-platform/azure-active-directory)* - I'm looking forward to the day that I this isn't such a pain in the ass for me to set up.
 - *[PaaS](https://azure.microsoft.com/en-us/overview/what-is-paas/)* - I see the industry going toward containers and/or PaaS, so I need to keep my head in the game with PaaS.
 - *Networking* - [Michael](hedge-ops.com) and I were trying to set up a network at home for our lab here, but we hit a few dead ends. I'm surely planning on a tutorial for how we set that up because that will be a feat once we finish. Lots of trial and error.

## CONTAINERS
Containers are all be new to me! But this is obviously the direction in which we can see the industry moving, so I’d love to keep up with it. I originally thought that it would be after more mastery of the other topics, but I'm working on Docker right now, and it's more accessible than I thought it would be.

 - *[Docker](https://www.docker.com/)* - This is super fun to learn and not as complicated as I thought.
 - *[Mesosphere](https://mesosphere.com/)* - This is a little scary for me, but I'm excited about it.
 - *[Kubernetes](http://kubernetes.io/)* - This is new to me, too, so the more the merrier.
 - *[Serverless](https://azure.microsoft.com/en-us/services/functions/)* - I don't even know, seriously.

This past week, I've been working on the first steps needed to take in moving forward with this training plan. I'm loving it! I'm working on Jenkins/Chef/Terraform/Docker in the next two weeks. Currently, I just created my first Jenkinsfile and am taking a Pluralsight course on Docker to extend the pipeline. It's so fun!

Stay posted for a blog post about how to create a dotnet core build in Jenkins!

# Concluding Thoughts
Currently I'm taking a [Pluralsight course on Docker](https://app.pluralsight.com/library/courses/docker-windows-getting-started/table-of-contents) by Wes Higbee, and he talks about how learning Docker is a sort of inverted learning because it allows you to use software without knowing how to set it up. So then when you're ready, everything is consistently documented for you to learn how to set it up later when you see your Dockerfile. That's exactly what I did with learning InSpec, though, so it was cool to hear him put a name to it. I had no idea of what InSpec was testing; I just knew that I was testing stuff. And so I was able to build from that and use InSpec as a springboard for further learning. With that in mind, one might consider Docker as an excellent tool for lowering the barrier to entry into technology. More to come on this topic because it's truly fascinating to me and important to the industry. 