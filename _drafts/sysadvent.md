# Running InSpec as a Push Job...or...The Nightmare Before Christmas

> Bored with his Halloween routine, Jack Skellington longs to spread Christmas joy, but his antics put Santa and the holiday in jeopardy! - [Disney](http://movies.disney.com/the-nightmare-before-christmas)

I feel a kindred spirit with Jack Skellington. I, too, wanted to spread some holiday-InSpec joy with my client, but the antics of their air-gapped environment almost put InSpec and my holiday joy in jeopardy. Sit back and let me tell the holiday tale of how I had no other choice but to use Chef push jobs to run InSpec in an air-gapped environment and why it almost ruined Christmas. 

Nothing would have brought me more holiday cheer than to be able to run run the tests as a `winrm` or `ssh` command from the Jenkins server directly from a profile on the git server, not checked out. However, my soul sank as I uncovered reason after reason for the lack of joy for the season:

Scroogey Problems:
1) _Network Connectivity:_ The clusters are in an air-gapped environment, and we needed InSpec to run every time a new sql instance was added.
2) _Jumpbox Not an Option:_ I could have PowerShell remoted into the jumpbox and run my InSpec command remotely, but this was, again, not an option for me because I had to create an elaborate attributes file based on data bags in the cookbook.
3) _SSL Verification:_ There is an SSL error when trying to access the git repo in order to run the InSpec profile remotely. Chef is working on a feature to disable SSL verification. When that is ready, we can access InSpec via a git link but not now. 

Because we were already using push jobs for other tasks, I finally succumbed to the idea that I would need to run my InSpec profiles as ::sigh:: push jobs.

Let me tell you real quickly what a push job is. Basically, you run a cookbook on your node that allows you to push a job from the Chef server onto your node. When you run the push jobs cookbook, you define that job with a simple name like "inspec" and what it does, for example: `inspec exec .`. Then you run that job with a knife command, like `knife job start inspec mynodename`.

Easy, right? Don't get so cheery yet.

This was the high level of what would have to happen, or what you might call the _top-of-the-Christmas-tree_ view:
1) The InSpec profile is updated.
2) The InSpec profile is zipped up into a `.tar.gz` file using `inspec archive [path]` and placed in the `files/default` folder of a wrapper cookbook to the cookbook that we were testing. (The good thing about using the archive command is that it versions your profile in the file name.)
3) The wrapper cookbook with the new version of the zipped up InSpec profile is uploaded to the Chef server.
4) Jenkins runs the wrapper cookbook as a push job when a new sql instance is added, and the zipped up InSpec profile is added to the node using Chef's file resource.
5) During the cookbook run, an attributes file is created from a template file for the InSpec profile to consume. The push jobs cookbook has a whitelist attribute to which you add your push job. I created an attribute for that attribute that looks like this:
```
node['push_jobs']['whitelist'] = {
  'chef-client' => 'chef-client',
  'inspec' => node['mycookbook']['inspec_command']
}
```
The `inspec_command` attribute looked like this:
```
"C:/opscode/chef/embedded/bin/inspec exec #{Chef::Config[:file_cache_path]}/cookbooks/mycookbook/files/default/mycookbook-inspec-#{default['mycookbook']['inspec_profile_version']}.tar.gz --attrs #{default['mycookbook']['inspec_attributes_path']}"
```
6) Another Jenkins stage is added that runs the "inspec" push job.

And all of that needs to be automated so that it actually stays updated. Yay...

I will not get into the gorey details of automating this process, but here is the basic gist. It is necessary to leverage a pull request build in git for the InSpec profile that:
- archives the profile after it merges into master
- checks out the wrapper cookbook and creates a branch
- adds to new version of the profile to the files/default directory
- updates the InSpec profile version number in the attributes file
- makes a pull request to the wrapper cookbook's master branch that also has a pull request build which ensures that Test Kitchen passes before it is merged

So...this works, but it's not fun at all. It's definitely the Nightmare Before Christmas and the Grinch Who Stole Christmas wrapped up into one. An alternative to doing it this way given our constraints would have been Salt and Chef Automate. 