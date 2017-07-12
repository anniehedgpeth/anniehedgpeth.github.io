---
layout: post
title:  "Deploying a Jekyll Website using Azure Web App with VSTS"
date:   2017-07-30 12:00:00
categories: visual studio team services, azure web app, vsts, azure, jekyll
tags: visual studio team services, azure web app, vsts, azure, jekyll
image: /assets/article_images/2017-04-08-test-kitchen/test-kitchen.jpg
image2: /assets/article_images/2017-04-08-test-kitchen/test-kitchen-mobile.jpg
---
Here's a fun exercise for you. Take the website that you made with a Jekyll template, and now deploy it into the Azure web app PaaS offering using Visual Studio Team Services. Let's go!

## Pre-requisites:
 - a [VSTS account](https://www.visualstudio.com/en-us/docs/setup-admin/team-services/sign-up-for-visual-studio-team-services)
 - an Ubuntu 16.04 running in Azure with [Docker installed](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04)
 "Docker on Ubuntu Server"

VSTS agent installed
https://github.com/Microsoft/vsts-agent/blob/master/docs/start/envubuntu.md

What steps do we need to create in order to deploy? Well, full disclosure, I can never get Jekyll running on my machine. I tried it on this Ubuntu, too, to no avail. That's why I had you install Docker, because we're not gonna mess with that nonsense.

docker run --rm --label=jekyll --volume=$(pwd):/srv/jekyll -it -p 127.0.0.1:4000:4000 jekyll/jekyll jekyll serve

https://github.com/jekyll/docker/wiki/Usage:-Running
sudo apt-get install zip

1. run `jekyll build` to create a `_site` folder
2. zip up `_site` folder
3. upload zip file to website


docker run --rm --label=jekyll --volume=$(pwd):/srv/jekyll -i -p 127.0.0.1:4000:4000 jekyll/jekyll jekyll build

Removed the 't' from -it because the agent is running, therefore I'm not running this Docker container interactively. There's no terminal with which to interact.

Agent 
https://www.visualstudio.com/en-us/docs/build/actions/agents/prepare-permissions

Install pre-reqs on Ubuntu: https://github.com/Microsoft/vsts-agent/blob/master/docs/start/envubuntu.md

'wget https://github.com/Microsoft/vsts-agent/releases/download/v2.119.1/vsts-agent-ubuntu.14.04-x64-2.119.1.tar.gz`

instructions:
https://www.visualstudio.com/en-us/docs/build/actions/agents/v2-linux

run config.sh

enter VSTS url
create token for server to use

7fvvkgrzerxwolq2gqfhleggcl2uauddgmrijxsxsqfmxsriuayq