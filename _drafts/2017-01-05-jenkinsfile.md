---
layout: post
title:  "Jenkinsfile"
date:   2017-01-05 12:00:00
categories: devops training, Jenkinsfile, jenkins, ci/cd, pipeline
tags: devops training, Jenkinsfile, jenkins, ci/cd, pipeline
image: /assets/article_images/2017-01-05-jenkinsfile/jenkinsfile.jpg
image2: /assets/article_images/2017-01-05-jenkinsfile/jenkinsfile-mobile.jpg
---
#TLDR:
*Use Jenkinsfile instead of the UI so that one ~ahem~ well-intentioned person can't ruin your build.*

> * #Resources
> * [Jenkinsfile documentation](https://jenkins.io/doc/book/pipeline/jenkinsfile/)
> * [Pluralsight: Getting Started with Jenkins 2](https://app.pluralsight.com/library/courses/jenkins-2-getting-started/table-of-contents) by [Wes Higbee](https://twitter.com/g0t4) - *serious shoutout to this guy. His classes are perfect - very thorough and clear.*

#DevOps, Version Control, and Jenkinsfile
For real, though, one of the things I like most about DevOps principles is version control. Well, honestly, I have a love-hate relationship with it because Git still makes me sweat every time I do a pull request. 

Nonetheless, all DevOps starts with version control! It envelopes what [Chef](https://www.chef.io/) calls ["the coded business"](https://twitter.com/chef/status/783317258227548160), which includes the concepts of infrastructure as code, pipeline as code, testing, etc. The end result being total automation. Therefore, if you're trying out a product and can't make it do what you want it to do with code, then you should stop using it and find something else.

So when you're creating a CI/CD Pipeline in [Jenkins](https://jenkins.io/), I'm going to try to convince you to create the build using [Jenkinsfile](https://jenkins.io/doc/book/pipeline/jenkinsfile/) instead of the UI so that it is subject to your change control mechanisms already in place (source control) and so that one very well-intentioned person doesn't ruin your build.

#Pipelines
In super-simple terms, let me share with you my understanding of a Pipeline in Jenkins. While a *JOB* is a defined process, and a *BUILD* is the result of that *JOB* being carried out, a *PIPELINE* is a defined series of *JOBS* that can be interrupted in between processes by different events such as failed tests, approval, et. al.

So when we use a Jenkinsfile which is written in [Groovy](https://en.wikipedia.org/wiki/Groovy_(programming_language)) for Jenkins's Pipeline plugin, we're able to do a lot a lot of things that you can't do if you're just creating a bunch of builds in the UI. I'll show you a sample, and then I'll tell you what I mean by that.

#Sample
Right now I'm working on a build for [Michael's dotnet core application](https://github.com/mhedgpeth/cafe/). The Jenkinsfile code below is going to do this:

<img src='/assets/article_images/2017-01-01-devops-training-plan/jenkinspipeline.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

This is what the [whole file](https://github.com/mhedgpeth/cafe/blob/master/Jenkinsfile) looks like, but right now let's just take a look at the *compile* stage.

```groovy <linenumbers="normal">
#!/usr/bin/env groovy

stage('compile') {
  node {
    checkout scm
    stash 'everything'
    dir('src/cafe') {
      bat 'dotnet restore'
      bat "dotnet build --version-suffix ${env.BUILD_NUMBER}"
    }
  }
}
```



```
stage('test') {
    parallel unitTests: {
      node {
        unstash 'everything'
        dir('test/cafe.Test') {
            bat 'dotnet restore'
            bat 'dotnet test'
          }
      }
    }, integrationTests: {
        node {
          unstash 'everything'
          dir('test/cafe.IntegrationTest'){
              bat 'dotnet restore'
              bat 'dotnet test'
          }
        }
    },
    failFast: false
}
```

```
stage('publish') {
  parallel windows: {
    node {
      unstash 'everything'
      dir('src/cafe') {
        bat 'dotnet publish -r win10-x64'
        archiveArtifacts 'bin/Debug/netcoreapp1.1/win10-x64/publish/*.*'
      }
    }
  }, centos: {
    node {
      unstash 'everything'
      dir('src/cafe') {
        bat 'dotnet publish -r centos.7-x64'
        archiveArtifacts 'bin/Debug/netcoreapp1.1/centos.7-x64/publish/*.*'
      }
    }
  }, ubuntu: {
    node {
      unstash 'everything'
      dir('src/cafe') {
        bat 'dotnet publish -r ubuntu.16.04-x64'
        archiveArtifacts 'bin/Debug/netcoreapp1.1/ubuntu.16.04-x64/publish/*.*'
      }
    }
  }
}

```

#What you can't do in the UI
The UI is a tyical UI, right. It's there to help make some of the decisions for you. It wants to make your life easier, but everything in life is a tradeoff, so you have to sacrifice some functionality. 

 - You can't run parallel commands in the UI, just sequential.
 - You can't commit it to version control and have an approval and promotion process in the UI. 
 - You can't know what changes were made in the Pipeline.

The beauty of creating your Jenkinsfile for the Pipeline plugin is that you can manipulate it exactly the way that you want it. You have way more control and options than in the UI alone. The benefits that they make note of on [their website](https://jenkins.io/doc/book/pipeline/jenkinsfile/) are:
 - Code review/iteration on the Pipeline
 - Audit trail for the Pipeline
 - Single source of truth for the Pipeline, which can be viewed and edited by multiple members of the project.

#Concluding Thoughts

I told you in my last post that I've set a training plan for myself this coming year, and Jenkins was at the top of the list. And it's another one of those technologies that creates an inverted learning environment for me, as I touched on in my [last post](http://www.anniehedgie.com/devops-training-plan). The more I discover these technologies, the more encouraging it is to me that I don't have to know everything about everything to be able to add value. I can take something like Jenkins and learn a little about every aspect of deployment by creating builds. There are many learning opportunities wrapped up in technologies like this. More to come about inverted learning. My interest is piqued! 