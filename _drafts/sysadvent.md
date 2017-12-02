# Running InSpec as a Push Job...or...The Nightmare Before Christmas

> Bored with his Halloween routine, Jack Skellington longs to spread Christmas joy, but his antics put Santa and the holiday in jeopardy! - [Disney](http://movies.disney.com/the-nightmare-before-christmas)

<img src='https://media.giphy.com/media/4rKzbIk2U8dnW/giphy.gif' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

I feel a kindred spirit with Jack Skellington. I, too, wanted to spread some [holiday-InSpec joy](http://sysadvent.blogspot.com/2016/12/day-3-building-empathy-devopsec-story.html) with my client, but the antics of their air-gapped environment almost put InSpec and my holiday joy in jeopardy. All my client wanted for Christmas was to be able to run my InSpec profile in the Jenkins pipeline to validate configuration of their nodes, and I was eager to give that to them.

Sit back and let me tell the holiday tale of how I had no other choice but to use Chef [push jobs](http://sysadvent.blogspot.com/2013/12/day-9-getting-pushy-with-chef.html) to run InSpec in an air-gapped environment and why it almost ruined Christmas.

Nothing would have brought me more holiday cheer than to be able to run run the tests as a `winrm` or `ssh` command from the Jenkins server directly from a profile it a git repository, not checked out. However, my soul sank as I uncovered reason after reason for the lack of joy for the season:

Scroogey Problems:
1) _Network Connectivity:_ The nodes are in an air-gapped environment, and we needed InSpec to run every time a node was added.
2) _Jumpbox Not an Option:_ I could have PowerShell remoted into the jumpbox and run my InSpec command remotely, but this was, again, not an option for me. You see, my InSpec profile required an [attributes file](http://www.anniehedgie.com/inspec-basics-10). An [attribute](https://docs.chef.io/attributes.html) is a specific detail about a node, so I had to create from a template in the Chef cookbook because I needed node attributes and [data-bag](https://docs.chef.io/data_bags.html) information for my tests that were specific to that particular Chef environment.
3) _SSL Verification:_ There is an SSL error when trying to access the git repo in order to run the InSpec profile remotely. Chef is working on a feature to disable SSL verification. When that is ready, we can access InSpec via a git link but not now.

Because we were already using push jobs for other tasks, I finally succumbed to the idea that I would need to run my InSpec profiles as ::sigh:: push jobs.

Let me tell you real quickly what a push job is. Basically, you run a cookbook on your node that allows you to push a job from the Chef server onto your node. When you run the push jobs cookbook, you define that job with a simple name like "inspec" and what it does, for example: `inspec exec .`. Then you run that job with a knife command, like `knife job start inspec mynodename`.

Easy, right? Don't get so cheery yet.

This was the high level of what would have to happen, or what you might call the _top-of-the-Christmas-tree_ view:
1) The InSpec profile is updated.
2) The InSpec profile is zipped up into a `.tar.gz` file using `inspec archive [path]` and placed in the `files/default` folder of a wrapper cookbook to the cookbook that we were testing. The good thing about using the archive command is that it versions your profile in the file name.
3) The wrapper cookbook with the new version of the zipped up InSpec profile is uploaded to the Chef server.
4) Jenkins runs the wrapper cookbook as a push job when a new node is added, and the zipped up InSpec profile is added to the node using Chef's file resource.
5) During the cookbook run, an attributes file is created from a template file for the InSpec profile to consume. The push jobs cookbook has a whitelist attribute to which you add your push job. You’re just telling Chef that it’s okay to run this job. Because my InSpec command was different each time due to the version of the InSpec profile, I had to create basically make the command into a variable, so that meant I had to nest my attributes, which looks like this:
```
node['push_jobs']['whitelist'] = {
 'chef-client' => 'chef-client',
 'inspec' => node['mycookbook']['inspec_command']
}
```
The `inspec_command` attribute was defined like like this (more nesting):
```
"C:/opscode/chef/embedded/bin/inspec exec #{Chef::Config[:file_cache_path]}/cookbooks/mycookbook/files/default/mycookbook-inspec-#{default['mycookbook']['inspec_profile_version']}.tar.gz --attrs #{default['mycookbook']['inspec_attributes_path']}"
```
6) Another Jenkins stage is added that runs the "inspec" push job.

And all of that needs to be automated so that it actually stays updated. Yay...

I will not get into the details of automating this process, but here is the basic idea. It is necessary to leverage a build that is kicked off in Jenkins by a pull request made in git. That build, which is a Jenksinsfile in my InSpec profile, does this:
- archives the profile after it merges into master
- checks out the wrapper cookbook and creates a branch
- adds to new version of the profile to the files/default directory
- updates the InSpec profile version number in the attributes file
- makes a pull request to the wrapper cookbook's master branch that also has a pull request build which ensures that Test Kitchen passes before it is merged

So...this works, but it's not fun at all. It's definitely the Nightmare Before Christmas and the Grinch Who Stole Christmas wrapped up into one. It takes a few plugins in both Jenkins and BitBucket, which can be difficult to pull off if you don’t have admin rights. I used this [blog post](http://hedge-ops.com/cookbook-pipeline-with-jenkinsfile/) as a reference. 

I battled internally with a simpler way to do this. A couple of nice alternatives could have been [Saltstack](https://saltstack.com/) and [Chef Automate](https://docs.chef.io/chef_automate.html), but neither of those were an option for me. I’m not familiar with Saltstack, but I’m told that its [remote execution](https://saltstack.com/remote-execution/) feature would be able to run InSpec in an air-gapped environment. Likewise, Chef Automate has the [Chef Compliance](https://www.chef.io/automate/#automate-compliance) feature which runs all of your InSpec profiles from the Compliance server that you can put in your network. I’m still on the fence about whether those would have been easier to implement, though, because of the heavy dependence I had on the node attributes and data-bags that are stored on the Chef server.

As ugly as this process is, every time I see those all successful test results displayed in the Jenkins output, I can't help but put a big ol' jolly smile on my face. Sure, it super sucks to jump through all these hoops to get InSpec to work in this environment, but it when the automation works, it just works and no one knows what I had to go through to get it there. It's like a Christmas miracle.

Do I recommend doing it this way if you don't have to? No. Is this a great workaround if you have no other way to validate your configuration? Absolutely.

And if you need further convincing of the Christmas magic of InSpec, be sure to read my post last year about [how InSpec builds empathy across organizations](http://sysadvent.blogspot.com/2016/12/day-3-building-empathy-devopsec-story.html).

I hope you enjoyed my post! Many special thanks to [Jan Ivar Beddari](https://twitter.com/beddari) for editing this post and to [Chris Webber](https://twitter.com/cwebber) for organizing this very merry blog for all of us! You can follow me on Twitter [@anniehedgie](https://twitter.com/anniehedgie). If you'd like to read more about InSpec, I wrote a whole tutorial series for you to follow [here](http://www.anniehedgie.com/inspec/). And if you'd like me and my team at [10th Magnitude](https://www.10thmagnitude.com/contact/) to help you out with all things Azure, [give us a shout](https://www.10thmagnitude.com/contact/)!
