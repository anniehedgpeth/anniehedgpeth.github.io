---
layout: redirect
title:  "My Chef Workflow"
date:   2016-08-17 03:00:00
categories: chef, chef workflow, devops
tags: chef, chef workflow, devops
image: /assets/article_images/2016-08-17-my-chef-workflow/my-chef-workflow.png
image2: /assets/article_images/2016-08-17-my-chef-workflow/my-chef-workflow-mobile.png
redirect: https://hedge-ops.com/my-chef-workflow
---
Ever since I started [learning to remediate](http://www.anniehedgie.com/red-green-refactor) my InSpec test failures, I started learning bits and pieces of Chef. I started out in the [Test Kitchen](http://kitchen.ci/), quite appropriately, and since then I've been learning how to zoom out little by little so as to see the forest for the trees. 

And because this blog serves selfishly as a place to store all of my notes for future use but also a place where noobs (I really prefer newbs, but whatev) like me can benefit, I'm going to share my current notes for how I started from scratch and now currently maintain the process of Cheffing up my pipeline.

Here's what I'll do:

1. [Set up connection from local machine to Chef server](#set-up-connection-from-local-machine-to-chef-server)
2. [Bootstrap the node](#bootstrap-node)
3. [Do the Real Work Now](#do-the-real-work-now)
4. [Install and upload policy to Chef server](#install-and-upload-policy-to-chef-server)
5. [Converge the node](#converge-the-node)
6. [Scan for compliance errors on Compliance server](#scan-for-compliance-errors-on-compliance-server)

# Set up connection from local machine to Chef server
First, I need to have an account on [manage.chef.io](https://manage.chef.io/login) so that my local computer can talk to their server. This establishes a connection for communication. After that I'm able to upload all of my cookbooks to the server so that I can converge any node I want to with those cookbooks.

1. Create `chef_repo` folder *(You can call it whatever you want.)*
2. Inside that, create `.chef` folder *(You can't call it whatever you want.)*
3. On the Chef server in my web browser, click on **Admin** tab and click on my organization
4. Click **Generate Knife.rb**
5. Go to **Users** and select my user
6. Click **Reset key** and click **download**
7. Copy those files from the Download folder to the `.chef` folder
8. Run `knife ssl fetch`

# Bootstrap node
The next thing I need to do is set up a line of communication between my the node(s) and the Chef server. This, however, is done on my local machine. The `knife bootstrap` command installs chef-client on the node that I'm bootstrapping. This process now allows my node(s) to communicate with the Chef server. And the Chef server makes the cookbooks available to the node(s) for convergence. 

1. On my local machine, I'm going to run `knife bootstrap`
`knife bootstrap <ipaddress> -x <nodeUsername> -P <nodePassword> --sudo --policy-group <PolicyGroupName> --policy-name <nameInPolicyfile> -N <NodeName>`
2. Now I'm going to go to my node, and I want to ensure that the following lines are in `/etc/chef/client.rb`
 -  policy_name "\<your-policy-name>\"
 -  policy_group "\<your-policy-group-name>\"
 -  use_policyfile true

# Do the Real Work Now
This is where I'd start if I had already completed the setup of my connection to the Chef server and bootstrapped my node. So for all of the rest of my check-ins, I'll need to double-check that all of this is complete before I make any changes to my policy.

1. Code changes for cookbook
 - adding / editing cookbook files
 - adding / editing InSpec profiles
2. Make sure everything passes
 - Converge all resources successfully in Test Kitchen.
 - All tests pass.
3. Update version in metatdata.rb
4. Commit and push to Github
5. Now I'm ready to put this version into production

# Install and upload policy to Chef server
First of all, I know that you have two options here. You can go the policy file route, or you can use Berkshelf. [Michael](http://hedge-ops.com) taught me the policy file route because that's his preference, and so I tasked him with writing his own blog post to explain why. I'll update you when he does.

So anyway, when I install a Policyfile in a cookbook, I'm then able to tell it all of the other cookbooks that I want to run at the same time and where to find them. So then the Chef server knows which cookbooks to put on which nodes because the nodes tell it which policy they have.

1. On your command line, from your cookbook directory in which the Policyfile.rb is located, remove the `Policyfile.lock.json` file if it exists by using `rm Policyfile.lock.json`
2. Run `chef install`
3. Run `chef show-policy` to get the Policy Group name as it shows the active policies for each group. It will be after the asterisk. 
4. Run `chef push <policyGroup> Policyfile.rb` (may have to use `sudo`)
5. Run `chef show-policy` again to show the active policies for each group. The ID it uses should match the ID inside of the json file. (It's the first number `revision_id`, and it will only give you the first 10 digits.)
6. Commit to Git so that you can have a history of the json for every time you do this. (You can call it "updated policy" in your commit message.)

# Converge the node
When I'm converging a node, I'm basically running the chef-client command which runs all of the recipes and cookbooks that are in the Policyfile on the node(s). 

1. On a new terminal, open an ssh session to the node. 
2. Run `sudo chef-client`

# Scan for compliance errors on Compliance server
After I've converged the node(s), then I want to scan them so that I can see what, if anything, still needs to be remediated. You can go here to my [Tour of Chef Compliance](http://www.anniehedgie.com/tour-of-chef-compliance) if you need help remembering how to set it up.

1. Update your version number in the .yml file on your InSpec profile.
2. Compress the profile directory.
3. Upload the latest version of your profile to Compliance.
4. Add your node(s) to be scanned (check if IP address of VMs changed)
5. Scan your node(s) with the latest version of your profile.

# Next Step...Get Jenkins to do this for me

# Concluding Thoughts
I've had a few conversations recently about how I started my journey into technology in a bit of a backwards manner - learning the upper level stuff like automation instead of the foundational things like networks and hardware and a bunch of stuff that I don't know. But I really just wanted to start where there was a lowered barrier to entry and where the greatest demand for skills was, and I see that to be automation. My hope is that the foundational things will come in time and that the further I go in this journey, the clearer it will become where I should spend my time learning.

