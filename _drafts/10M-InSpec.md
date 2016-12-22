[<img src='https://github.com/anniehedgpeth/anniehedgpeth.github.io/blob/master/assets/images/InSpecLogo.png?raw=true' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />](http://inspec.io/)

One of my main goals at 10th Magnitude is to bring more security to all of our engagements. A way in which we can get a greater assurance of security is to not only to see the infrastructure as code but to see the compliance as code, also. A great framework in which to acheive this is an automated security and compliance auditing framework called [InSpec](http://inspec.io/). I'm going to share with you some very compelling reasons that you, too, might want to consider using it.

1. [Anyone can use it.](#1-anyone-can-use-it)
2. [Its strength is in its simplicity.](#2-its-strength-is-in-its-simplicity)
3. [You begin to see how much you need it.](#3-you-begin-to-see-how-much-you-need-it)

Full disclosure: All of these thoughts are my own, and I was not paid by Chef to write about InSpec. I just really like it!

#1. Anyone can use it.
When I heard that InSpec was written with non-developers in mind, I set about on a mission to prove whether that was true. At the time I had no development experience at all, so learning InSpec myself made for a great experiment. I started to learn how to write InSpec audit controls, and I wrote a [series of tutorials](http://www.anniehedgie.com/inspec) along the way so that others could learn how to use it, too.

<img src='https://github.com/anniehedgpeth/anniehedgpeth.github.io/blob/master/assets/images/blogscreenshot.png?raw=true' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />

One very important thing that I proved throughout this blog series was that InSpec is completely accessible. I began the series with a very simple ['Hello World'](http://www.anniehedgie.com/inspec-basics-1) tutorial in which I first laid out at a very basic level how to install InSpec on a Mac and then how to write your very first audit control test with InSpec. I wrote it from a perspective that the reader was not a technically-minded person, so really anybody can follow this tutorial.

```ruby
control "world-1.0" do                                # A unique ID for this control
  impact 1.0                                          # Just how critical is
  title "Hello World"                                 # Readable by a human
  desc "Text should include the words 'hello world'." # Optional description
  describe file('hello.txt') do                       # The actual test / Resources 
   its('content') { should match 'Hello World' }      # Custom matchers
  end
end
```

Another aspect of its accessibility is that, while InSpec is owned by [Chef](https://www.chef.io/), it's completely platform agnostic, and you don't even need configuration automation to use it! When you scan your infrastructure, nothing gets installed, changed, or configured on the node that you're testing.

#2. Its strength is in its simplicity.
InSpec has a number of [different resources](http://inspec.io/docs/reference/resources/) to use in your audit controls, but at the heart of all of them is either searching a file or directory or running a command. In [Day 2](http://www.anniehedgie.com/inspec-basics-2) and [Day 3](http://www.anniehedgie.com/inspec-basics-3) of the tutorial series, I taught how to use both the file resource and the command resource - the meat and potatoes of InSpec. When someone is equipped with just these two resources, they can get pretty far with creating their own auditing controls! 

```ruby
describe file('/etc/yum.conf') do                    # Searching a file
  its('content') { should match /gpgcheck=1/ }       # Using the "Content" matcher
end

describe command('rpm -q --queryformat "%{SUMMARY}\n" gpg-pubkey') do  # Running a command 
   its('stdout') { should match (/[0-9]/) }                            # Matching its standard output
end
```

After you've experimented with that sufficiently, you can start learning how to use all of the other resources at your disposal at [InSpec](http://inspec.io/)'s website as well as custom matchers, which I teach you how to choose in [Day 4](http://www.anniehedgie.com/inspec-basics-4).

The other aspect of its simplicity that I really love is that you can run the profiles (a grouping of audit controls) from anywhere! You can learn how to create a profile on [Day 5](http://www.anniehedgie.com/inspec-basics-5). In [Day 6](http://www.anniehedgie.com/inspec-basics-6), you learn that you can store them locally, in version control, in the [Chef Supermarket](https://supermarket.chef.io/tools?type=compliance_profile), or on the [Chef Compliance](https://docs.chef.io/compliance.html#) server (if you have a Chef enterprise license, then you'll want to read [Day 7](http://www.anniehedgie.com/inspec-basics-7) about inheriting profiles from the Compliance server).

[<img src='https://github.com/anniehedgpeth/anniehedgpeth.github.io/blob/master/assets/article_images/2016-06-09-inspec-basics-6/whereandhow.png?raw=true' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />](http://www.anniehedgie.com/inspec-basics-6)

And because you can store them anywhere, that gives you many options about how and where to use InSpec. Take a look at these commands that you can run in order to run a profile on a node:

```bash
# run test locally
inspec exec test.rb

# run test on remote host on SSH
inspec exec test.rb -t ssh://user@hostname -i /path/to/key

# run test on remote host using SSH agent private key authentication. Requires InSpec 1.7.1
inspec exec test.rb -t ssh://user@hostname

# run test on remote windows host on WinRM
inspec exec test.rb -t winrm://Administrator@windowshost --password 'your-password'

# run test on docker container
inspec exec test.rb -t docker://container_id
```

Now imagine that you can put the link to a stored InSpec profile where it says `test.rb`. If you have [InSpec installed]((http://www.anniehedgie.com/inspec-basics-1)) on your machine, then you can run either of these commands right now using a profile stored on the Chef Supermarket to verify that all updates have been installed on a Windows machine.

```bash
# run test stored on Github locally 
inspec exec https://github.com/dev-sec/windows-patch-baseline

# run test stored on Github on remote windows host on WinRM
inspec exec https://github.com/dev-sec/windows-patch-baseline -t winrm://Administrator@windowshost --password 'your-password'
```
Now imagine putting those commands in a CI/CD pipeline and using them across all of your environments. So many possibilities!

#3. You begin to see how much you need it.
Imagine a world in which security and compliance is not an afterthought, but it's brought in from the very beginning and compliance issues and bugs are found with InSpec in development instead of waiting all the way until the end with a slow manual check, delaying release to production.

If your company requires strict adherance to regulatory requirements, then you definitely know that you can benefit from an automated auditing tool. Imagine being able to create a profile that tests for CIS compliance, and instead of auditing it manually once at year, you run that profile every single time someone changes something at any stage in the pipeline! 

Also imagine that you have run all your configuration scripts, and instead of hoping for the best, you actually created an InSpec profile that validates all of your configuration. InSpec will be your safety net before deploying! 






  - [Hello World](http://www.anniehedgie.com/inspec-basics-1) 
  - [Command Resource](http://www.anniehedgie.com/inspec-basics-2)
  - [File Resource](http://www.anniehedgie.com/inspec-basics-3)
  - [Custom Matchers](http://www.anniehedgie.com/inspec-basics-4)
  - [Creating a Profile](http://www.anniehedgie.com/inspec-basics-5)
  - [Ways to Run It and Places to Store It](http://www.anniehedgie.com/inspec-basics-6)
  - [How to Inherit a Profile from Chef Compliance Server](http://www.anniehedgie.com/inspec-basics-7)
  - [Regular Expressions](http://www.anniehedgie.com/inspec-basics-8)
  - [Attributes](http://www.anniehedgie.com/inspec-basics-9)
  - [Attributes with Environment Variables](http://www.anniehedgie.com/inspec-basics-10)