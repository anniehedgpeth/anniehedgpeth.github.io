---
layout: post
title:  "Docker For Windows"
date:   2017-01-17 12:00:00
categories: devops training, Docker, windows, jenkins, ci/cd, pipeline, Learning
tags: devops training, Docker, windows, jenkins, ci/cd, pipeline, lowering the barrier to entry, learning
image: /assets/article_images/2017-01-17-docker2/docker2.jpg
image2: /assets/article_images/2017-01-17-docker2/docker2-mobile.jpg
---
Last week I explained how Docker is a great tool for lowering the barrier to entry into technology through an inverted learning style. And today I'll get into a little more of the nuts and bolts of Docker for Windows and how you can get started playing around with it.

# Difference Between Docker 'On' Windows and Docker 'For' Windows
The main difference of which you need to be aware is that you'd only use [*Docker For Windows*](https://docs.docker.com/docker-for-windows/) in development, not production. And the reason for that is tied up in the shared kernel. If you want to run a Linux container in *Docker For Windows*, then Hyper-V will provide that isolation by providing a MobyLinuxVM for you. However, when you're in production and are more concerned about speed and streamlining, you'd want to run your Linux container on a Linux box so that it can share the kernel.

That said, if you're on Windows (which I'm generally not, but I'm broadening my horizons) and want to use *Docker For Windows* as a testing environment, then it works great because you don't have to spin up a Linux VM. So that's what I'm doing.

# Getting Started with Docker For Windows
At the risk of sounding like a total advertisement, Docker really does make getting started with it super simple. I'm not going to give you a tutorial, because there's already a really good one [here](https://docs.docker.com/docker-for-windows/), complete with a *'hello world'*. But as a quick reference, I'll give you the most [common commands](https://docs.docker.com/engine/reference/commandline/) that you'll run across.

```bash
# pull an image
$ docker pull <image>

# create a container from an image
$ docker create <image>

# run the container
$ docker start <container>

# stop the container
$ docker stop <container>

# remove the container
$ docker rm <container>

# Do ALL of the above with one command
$ docker run <container>
```

# My Workflow
I told you that my [hubs](http://hedge-ops.com) is creating an [open source application](https://github.com/mhedgpeth/cafe/) that's going to make your life a lot easier if you're running [Chef](https://chef.io) on Windows. So I'm building his CI/CD pipeline in Jenkins and creating a Docker image in *Docker For Windows* to test the application before it goes to production. And in that [Jenkinsfile](http://www.anniehedgie.com/jenkinsfile) that I told you about I hadn't gotten to running Docker yet. 

So now I'm running a [Dockerfile](https://docs.docker.com/engine/reference/builder/) in that Jenkinsfile, which is pretty darn cool. All a Dockerfile does is take all the bash shell commands that you'd run and put it into a nice, neat, consolidated little script. So before I show you that Dockerfile, let me show you what commands would I use to create the image that I want to create:

```bash
docker run -d --name ${target} microsoft/windowsservercore
docker run -d --name ${target} centos
docker run -d --name ${target} ubuntu:xenial
```

Right here I'm running a command to create an image for each of the different targeted machines.

```bash
docker cp ./bin/Debug/netcoreapp1.1/${target}/publish/. ${target}:/usr/share/cafe
```

And here I'm copying files/folders from a container to a HOSTDIR. This is because it's where the application needs to run. *************This isn't right.**************

```bash
docker commit ${target} cafe:windows
docker commit ${target} cafe:centos
docker commit ${target} cafe:ubuntu
```

And now I'm creating a new image from a container’s changes.

```bash
docker stop CONTAINER ${target}
```

And you can probably figure out what I'm doing here. So after all of that, I have three shiny new images ready to use in which I can run my application.

# My Dockerfile
First of all, I added this one simple line to my Jenkinsfile to get it to run my [Dockerfile](https://docs.docker.com/engine/reference/builder/).

```groovy
bat "docker build -f Dockerfile-${imageLabel} -t cafe:${imageLabel} ."
```

And then I had to build a Dockerfile for each image that I wanted to create: Centos, Ubuntu, and Windows. They look like this:

```
FROM centos

MAINTAINER Annie Hedgpeth <annie.hedgpeth@gmail.com>

COPY bin/Debug/netcoreapp1.1/centos.7-x64/publish /usr/bin/cafe/

EXPOSE 59320

ENTRYPOINT ["/usr/bin/cafe/cafe"]
CMD ["server"]
```

To me, all of the syntax isn't all that intuitive, but such is life. 

`FROM` is where I indicate from which base image I want to build my image on top. That's one of the things that the `docker run` command did up above.

`MAINTAINER` is just allowing for some friendly metadata.

`COPY` is doing exactly what `cp` does, mentioned above.

`EXPOSE` is telling that container to listen on that port.

`ENTRYPOINT` allows you to configure a container that will run as an executable, which is what I want to do to test this application. You can do this on the command line when you run:

```bash
docker run -it --rm -p 80:80 nginx
```

The `-it`option makes the image interactive, and `--rm` removes it when you're finished with it. `80:80` is the port, and `nginx` is the image.

`CMD ["server"]` *****************I have no idea what this does. I know it runs the proceeding command, but I don't know what "server" does.****************

# Concluding Thoughts
***********************I feel like I need to get this working before I can finish this post.*********************