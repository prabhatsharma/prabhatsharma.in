---
title: "Learning Kafka by doing: Using Amazon MSK"
date: 2020-01-30T07:25:12-08:00
draft: true
tags: ["streaming", "managed service", "cloud", "aws", "data engineering", "kafka"]
author: Prabhat Sharma
type: post
image: images/blog/kafka/kafka-logo.png
---


Apache kafka is a very popular choice for processing streaming data. While there are countless articles explaining what it is and how it works, nothing beats doing stuff yourself when it comes to learning. And learning by writing code yourslef as you would do when you are building your own applications instead of using the standard cookie cutter available CLI is awesome.

So let's start our journey.

For us to start we will first need a cluster that we write our applications against. While you can install it on your local machine for testing, or in a kubernetes cluster using a helm chart or an operator, we would use Amazon MSK (Managed Streaming for Kafka) in this case. Kafka is not one of the easy pieces of an infrsatructure to manage, right from manageing servers for kafka to requirement of zookeepr, updates, upgrades, security patches, storage, backup, etc. Managed services like Amazon MSK make life so much easier when you want to run these services.


We will try o setup a minimal kafka cluster. MSK supports certificate based authentication which requires you to have a private CA in ACM. We will do our stuff without authentication for time being. You can create a cluster using AWS console by visiting https://console.aws.amazon.com/msk/home.

We will install MSK in a private subnets in a VPC. Go ahead and create your VPC with public and private subnets. Here is what looks like when its created:

You can create a setup like below using cloudfromation. There are some readymade templates from cloudonaut that you can use. Head to https://templates.cloudonaut.io/en/stable/vpc/ to check them.

<!-- <a href="https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://s3-eu-west-1.amazonaws.com/widdix-aws-cf-templates-releases-eu-west-1/stable/vpc/vpc-3azs.yaml&stackName=vpc"> <img src="/images/blog/kafka/launch-stack.png"></a> -->

<!-- VPC

<img src="/images/blog/kafka/vpc.png" width="100%">


Subnets

<img src="/images/blog/kafka/default-vpc-subnets.png" width="100%">

Public route table

<img src="/images/blog/kafka/public-route-table.png" width="100%">

Private route table

<img src="/images/blog/kafka/private-route-table.png" width="100%"> -->

<!-- Follow steps 1, 2 and 4 from https://docs.aws.amazon.com/msk/latest/developerguide/getting-started.html to create following:
VPC -->


Once you have your public and private subnets ready, we are ready to launch the cluster.

