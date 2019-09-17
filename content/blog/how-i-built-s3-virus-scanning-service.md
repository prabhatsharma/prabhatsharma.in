---
title: "How I Built S3 Virus Scanning Service"
date: 2019-09-01T11:23:09-07:00
draft: true
tags: ["k8s", "kubernetes", "s3", "virus", "security"]
author: Prabhat Sharma
type: post
---


•	Amazon S3 holds trillions of objects and regularly peaks at millions of requests per second.
•	In a single region, S3 processes peaks of over 60 tbps of traffic in a day. [November 28, 2018]
