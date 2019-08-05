---
title: "Best way to build website and blog in 2018"
date: 2018-10-09T15:37:09-07:00
image: images/blog/my-website.png
draft: false
tags: ["website", "blog", "hosting", "wordpress"]
author: Prabhat Sharma
type: post
---

Beware!!! opinions ahead!!!

I am asked by multiple people on what is the best way to build a small website and maybe build a blog as well. For long time wordpress has been the choice of application with other CMSs like drupal, joomla, etc as contenders. On the blogging front the contenders have been like ghost. Also there have been online applications like medium and tumblr that are doing the job pretty well. Then there are static website generators like jekyll and hugo.

All of these have their pros and cons and there is no one size fits all solution. Let's look at each of these various category of solutions.

## Content management systems/blogging applications (wordpress, drupal, ghost)

Applications like wordpress and drupal provide a very good interface and usability for users with wide community support and these has been around for many years now. You have couple of options to host these:

1. Set up your own servers (or ec2 instances on AWS or similar on other cloud providers) and host them.
2. Buy a shared hosting service like wordpress.com, wix, etc... 
3. Use a service like AWS lightsail.

Drawbacks with any of these approaches is that:

1. Manage the application if self hosted.
1. Maintenance is a challenge.
1. Database backups and restores are pain unless you have DBA skills and actually want to do these.
1. Securing these applications is a big challenge. I have heard of numerous horror stories of wordpress sites being hacked.
1. Scaling is a challenge. A good problem to have is getting tons of traffic to your website/blog. However how do you do scaling with wordpress or your own self hosted applications. Not that it can't be done but its good amount of work.

## Services like wordpress.com, wix, ghost.com, medium, tumblr

These are pretty good solutions to get started with to build an online presence. However you are limited to the stuff that these service providers provide you. Anything custom that you want to do that is not compatible with their service, you are out of luck. In most cases you pay a flat monthly fees to operate the app.

## Static site generators (hugo, jekyll, etc)

This is currently my favorite mechanism to build a website or blog. The way I recommend implementing these is by generating a static website using [hugo](https://gohugo.io). It takes less than 30 minutes to build a static website and blog. 

I will provide brief steps for setting it up on AWS.

Once you have generated the website and created content you can upload them to S3 using a simple command like:

``` shell
aws s3 sync ./public s3://<bucket-name>/ --acl=public-read
```

You can find exact steps and documentation on [aws website](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html)

Now you want to put a cloudfront distribution in front of S3 bucket hosted website to make it highly performant. Get the steps on [cloudfront documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GettingStarted.html).

Bonus on AWS is that you can get a SSL certificate for free using ACM :-).

![Architecture](/images/blog/website-architecture.png)


Advantages of using this approach:

1. Cheapest solution - No fixed cost. You pay only for what you use which is minimal depending on website traffic. I have had sites like this running for many months now and I have hardly paid a couple of dollars.
2. Most scalable solution - Can scale to millions of hits without any intervention
3. Solution that has least maintenance - It's like set it and forget it.
4. Solution that is most secure - No servers hence no security concern.
5. New posts and deployments can be in source control like github. In case of wrong deployments just release last version.
6. Is highly performant. How fast did you feel this page was loaded. Try refreshing it again to see :-)

This is how I have built [https://prabhatsharma.in](https://prabhatsharma.in) that hardly costs me anything and has just 2 components in its architecture. Go ahead, give it a shot. You will love it.
