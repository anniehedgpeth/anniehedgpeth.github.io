---
layout: post
title:  "Tutorial for Setting Up Chef Compliance Server on Azure"
date:   2016-05-04 20:05:00
categories: tutorial, chef, compliance, azure, security
tags: tutorial, chef, compliance, azure, security
image: /assets/article_images/2016-05-05-setting-up-compliance/chef-compliance.jpg
image2: /assets/article_images/2016-05-05-setting-up-compliance/chef-compliance-mobile.jpg
redirect_to: https://hedge-ops.com/setting-up-compliance
---
This tutorial for setting up [Chef Compliance](https://www.chef.io/compliance/) is for pretty much anyone to use. I break it into extremely simple steps, so that there is no mystery.

The thing about setting up Chef Compliance that was challenging for me is that you can't see the product until you build a home for it. It was a lot like taking a giant box home from Ikea when you don't know what you bought, then you have to put it together with random instructions strewn together from blogs.   
<!--more-->

As a non-technical type who's been into technology for all of about five minutes, I am teaching myself to not be scared of technology. True, I’m most likely not the next Steve Jobs, but I did prove that I can now set up a virtual machine to use Chef Compliance in the cloud, and you can, too! 

Disclaimer: I'm not a prodigy; I just have a totally unfair advantage, and his name is Michael Hedgpeth of [hedge-ops.com](http://hedge-ops.com). I'm married to him, and thus have a totally awesome teacher with benefits. So there's that. 

I will say, however, that I did not move from one step to the next without fully understanding what I was doing and the context with which I was doing it.

## What You Will Need

* a [Microsoft Azure](https://portal.azure.com) account (there are free trials if needed)
* knowledge of basic Ubuntu command line (I [took a course](https://www.lynda.com/Ubuntu-tutorials/Working-command-line/159637/179585-4.html) on basic Linux command line at [lynda.com](http://www.lynda.com))

## Overview of the steps
1. [Create an Ubuntu virtual machine on Azure](#create-an-ubuntu-virtual-machine-on-azure)
2. [Make your virtual machine accessible over the internet](#make-your-virtual-machine-accessible-over-the-internet)
3. [Rename your virtual machine](#rename-your-virtual-machine)
4. [Set up Chef Compliance on your virtual machine](#set-up-chef-compliance-on-your-virtual-machine)
5. [Configure Chef Compliance server](#configure-chef-compliance-server)

## Create an Ubuntu virtual machine on Azure
We decided to use Azure because a) Virtual Box just didn’t work for us for whatever reason, and b) Michael is more familiar with Azure than AWS right now. Plus, they offer a free trial, so it worked out. If you have had better luck with virtual box, I'd love to hear about it!

1. Go to your [Azure](https://portal.azure.com) account and click **NEW**.
2. Under **Marketplace** click **Virtual Machines**
3. Under **Featured Apps** click **Ubuntu Server 14.04 LTS**
![](/assets/article_images/2016-05-05-setting-up-compliance/02-ubuntu-server.png)
4. Leave the default setting for **Select a Deployment Model as Resource Manager**
5. Under the **1 – BASICS – Configure Basic Settings** tab, fill in the following
  * **Username** – This is you. You’ll have to enter it several times, so make it simple.
  * **Password** – Choose a good one because it’s over the internet, but you will have to enter it, and I don’t know that you can copy and paste it.
  * **Resource Group** – Create a new one and name it. 
  * **Location** – Choose the location of your server that’s closest to your region.
6. Under the **2 SIZE** tab – A1 is what I chose, cheap and it did the job.
![](/assets/article_images/2016-05-05-setting-up-compliance/03-create-vm.png)
7. Under the **3  SETTINGS** tab – choose all defaults for **Storage** options.
8. Under the **4 Summary** tab – click ok and your VM will be deployed after a few minutes.

## Make Your Virtual Machine Accessible Over the Internet
We're doing this so that our browser can access Chef Compliance on our server. First, we'll register a public name for the server, so that we can type that name in a browser. Then we'll need to change the security settings on the network security group. 

1.	So go to **All Resources**, click on your server, then click on your **IP address** and note that there is no DNS name label for it. 
![](/assets/article_images/2016-05-05-setting-up-compliance/05-changing-dns.png)
2. Click on **Configuration** and add the name you choose in the box called **DNS name label** and copy it to notepad or something because you’ll need it later. Then click **SAVE** at the top of the **Configuration** tab.
![](/assets/article_images/2016-05-05-setting-up-compliance/06-configuration.png)
3. Go to the network security group (the one with the shield icon) that you just created. We need to create a rule so that our compliance website can be accessed. 
![](/assets/article_images/2016-05-05-setting-up-compliance/07-inbound-security-rules.png)
  * In settings, click on **Inbound Security Rules**. 
  ![](/assets/article_images/2016-05-05-setting-up-compliance/08-inbound-security-rules.png)
  * Click **ADD**, and name it **“allow-ssl”**, and change the **Destination Port Range** to **443** so that you can talk to the server over https. Then click **OK**.
![](/assets/article_images/2016-05-05-setting-up-compliance/09-add-rule.png)
  * Make sure your machine is on by going back to **All Resources** and clicking on your VM (with the monitor icon). If **Connect** is greyed out, then you’re connected.
![](/assets/article_images/2016-05-05-setting-up-compliance/10-make-sure-vm-is-on.png)

## Rename Your Virtual Machine
After all of that, your vm still doesn't really know that its name was changed, so now we have to tell it what its name is. 

1. SSH to your vm
  * Open up your terminal. 
  ```ssh username@dnsname```
  Mine was:
  ```ssh annie@cheftutorialcompliance.southcentralus.cloudapp.azure.com```
  * Respond `yes`
  * Enter your password
2. Install Nano on your VM 
```
sudo apt-get install nano
```
3. Open this file so that you can edit it
```
sudo nano /etc/waagent.conf
```
4. Find this in the document:
```
Provisioning.MonitorHostName=y
```
5. The value will be `n` when you find it, but change it to a `y`
6. Save by clicking `Ctrl+o`, then accept the file name by pressing **Enter**
7. Then Exit by clicking `Ctrl+x`
8. Once done, run this command
```
sudo waagent -install
```
9. Now change the name to the full domain name that you'll type in your browser. I used
```
sudo hostname cheftutorialcompliance.southcentralus.cloudapp.azure.com
```
When you finish this step you should be able to type the command `hostname` and something like `cheftutorialcompliance.southcentralus.cloudapp.azure.com` should come up. 

This is the terminal I used.
![](/assets/article_images/2016-05-05-setting-up-compliance/11-ssh-to-vm.png)

## Set Up Chef Compliance on Your Virtual Machine
Finally. After all of that work, we're ready to actually put Chef Compliance onto our virtual machine. I used this [guide](https://docs.chef.io/install_compliance.html).

1. To download the package, go to the [download site](http://downloads.chef.io/compliance/) get the download URL for Ubuntu and copy and paste the link on a notepad or something to use in a minute.
![](/assets/article_images/2016-05-05-setting-up-compliance/01-compliance-download.png)
2. cd to the /tmp directory
```
cd /tmp
```
3. wget the download URL
```
wget [download url that you just copied]
```
4. As the [directions say](https://docs.chef.io/install_compliance.html), run sudo dpkg
```
sudo dpkg -i /tmp/chef-compliance-<version>.deb
```
Hint: Just type up to chef, then hit tab to auto-fill. 
This will take a minute or so.
5. Run `sudo chef-compliance-ctl reconfigure`
6. This takes you to a license agreement. (Edited to add: They may have done away with this requirement.)
  * Hit any key. 
  * Read it as you scroll all the way down to the end. 
  * Then hit `q` to get out of the agreement. 
  * You then need to agree to it, so type `yes`, and it will load the compliance server. 
  * This will take a few minutes (if you got a slow, cheap machine like I did).

## Configure Chef Compliance Server
So now that it's all installed, it's time accept the license agreement and set up an administrator user so that you can start using the product. 

1. Navigate to your URL and add `/#/setup` to the end, make sure it's `https`
2. Your browser doesn't trust your server, so it'll warn you not to go there. Just click on **Advanced** and then accept the risk that it asks you to accept by clicking the link at the bottom.
![](/assets/article_images/2016-05-05-setting-up-compliance/14-accept-risk.png)
3. Click on **Setup Chef Compliance**
![](/assets/article_images/2016-05-05-setting-up-compliance/12-chef-compliance-setup.png)
4. Accept the license agreement...again
![](/assets/article_images/2016-05-05-setting-up-compliance/15-pasted1.png)
5. Set up an admin user and click **Next**
![](/assets/article_images/2016-05-05-setting-up-compliance/16-pasted2.png)
6. Make sure your info is correct and click **Configure**
![](/assets/article_images/2016-05-05-setting-up-compliance/13-failed.png)
The first time I went through, it said that the setup failed. But then I went back to the dashboard and logged in, and all was well. Who knows.
7. Go to the dashboard, and you're ready to go!
8. Now go have a glass of wine and a chocolate chip cookie and pat yourself on the back. 

## Concluding Thoughts
I gotta admit, this whole process was a bit much for me. I couldn't have done it without [Michael](http://hedge-ops.com). Once I got to the end, I was super surprised to see just how simple and intuitive the program was after such a complicated setup. 

I'm really excited to learn more about Chef Compliance, so in another post I'll get to the fun part where we actually get to play around with it and see just what it can do. 