---
layout: redirect
title:  "Elasticsearch Network Hosts"
date:   2016-09-04 03:00:00
categories: elasticsearch, network hosts, cookbooks, chef
tags: elasticsearch, network hosts, cookbooks, chef
image: /assets/article_images/2016-09-05-elasticsearch-network-hosts/elasticsearch.jpg
image2: /assets/article_images/2016-09-05-elasticsearch-network-hosts/elasticsearch-mobile.jpg
redirect: https://hedge-ops.com/elasticsearch-network-hosts
---
Hello, friends! I've missed you. I've been a busy bee. I got hired onto a contract-to-hire position at a consultancy for whom I'm working on a Chef project. I'm having a great time because I'm learning so much. To say that I'm drinking from a fire-hose is an understatement.

But I definitely want to slow down and share some breakthroughs so that I can remember them for later and hopefully help some of you out along the way. 

So I was tasked with creating a cookbook to spin up three nodes using Test Kitchen and to install elasticsearch onto said nodes. Easy enough? -_- 

Okay, so at first I was just hard-coding the `network_host` in my config because I just wanted to get it to work and I didn't really know how to get it from [ohai](https://docs.chef.io/ohai.html). Even understanding how attributes work took me a while to get up to speed, so then the complexity of using a complicated ohai value alongside attributes with node hashes and how it affects my kitchen.yml proved challenging for me. Let's just say there was more than one whiteboard session with my [favorite tutor](http://hedge-ops.com). 

But I really needed to get it from ohai so that the setup of the cookbook would be simpler. The thing that made it complicated to me was that there were so many IP addresses floating around with my multiple virtual machines in the elasticsearch cluster, and I had a hard time wrapping my mind around which was what. I had 3 nodes, one of which was a master/host, and I didn't know which IP address in ohai was going to be the one I needed to use for `network_host`.

Finding the proper IP address, however, ended up being simpler than I thought it would be. All I did was ssh into my master node in Kitchen:

`kitchen login master` 

Then, to make it simple to search my ohai data, I needed to save the output to a file. (Grepping it did me no good because I needed the larger context of its location.) So I ran:

`ohai >> ohai.txt`

Then I opened it in Nano so that I could search for my known IP address:

`nano ohai.txt`

After it was open, I did a search using `Ctrl +w` for "Where is". I knew my hard-coded IP address, so I searched for that. When I found it, I was stumped for a minute.

[<img src='/assets/article_images/2016-09-05-elasticsearch-network-hosts/ohai-ip.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />]

But then I realized that with this information, I could map out the structure in which the necessary IP address was. If I knew that structure, then I could code against that structure to map to my IP address, right? Right. So how to do it? Well, I don't know how you would have done it, but here's what [Michael](http://hedge-ops.com) and I worked out on Labor Day.

In a resource that was serving as a default yml for each of my nodes, I had the following code (only showing you the pertinent info). 


```ruby
interfaces = node['network']['interfaces']
interface_key = interfaces.keys.last
addresses = interfaces[interface_key]['addresses']
network_host = nil
addresses.each do |key, value|
  if value['family'] == 'inet'
    network_host = key
  end
end

elasticsearch_configure 'elasticsearch' do
  configuration(
    'network.host' => network_host,
end
```

So if we take it chunk by chunk, you can see what we did here. 

[<img src='/assets/article_images/2016-09-05-elasticsearch-network-hosts/ohai-network.png' style='display: block; margin-left: auto; margin-right: auto; padding-top: 40px' />]

When we scrolled up in our `ohai.txt`, we could see that at the top of the tree was the `"network"` and then the `"interfaces"` branches. So we needed to start there and climb down. `"interfaces"` had three different keys: `"lo"`, `"eth0"`, and `"eth1"` - in that order. And our IP address was in the last key for that branch, so you see what we did there.

```ruby
interfaces = node['network']['interfaces']
interface_key = interfaces.keys.last
```

So then I wanted to say that my `network_host` IP address was in the same branch of the tree or key that had the `family` key equal to `inet`.  

```ruby
network_host = nil
addresses.each do |key, value|
  if value['family'] == 'inet'
    network_host = key
  end
end
```

And that did it! I was able to call that variable in my config.

```ruby
elasticsearch_configure 'elasticsearch' do
  configuration(
    'network.host' => network_host,
end
``` 

And call it good. :)

# Concluding Thoughts
Everything seems hard until you break it into small, bite-sized, manageable chunks. I didn't want to deal with this issue, and so I put it off until the very end. But when I sat down, talked it through, and mapped it out with Michael, it was suddenly much more manageable. Sounds a lot like life!
