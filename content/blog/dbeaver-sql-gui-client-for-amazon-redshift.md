---
title: "DBeaver - SQL GUI Client for Amazon Redshift"
date: 2018-12-30T17:43:01-08:00
draft: false
image: images/blog/dbeaver-small.png
tags: ["redshift", "data warehousing", "aws", "amazon", "gui"]
author: Prabhat Sharma
type: post
---

I use redshift occasionally for playing with some data. Its an amazing service(a datawarehousing solution) from AWS that you can use for analyzing large amounts of data.

Every time I need to use redshift (every couple of months) I begin my search for a decent client that I can use. A google search does not result in something concrete right off with full of discussions on [quora](https://www.quora.com/What-is-the-best-SQL-client-on-Mac-for-working-with-Redshift) and other places.

AWS official guides use SQL workbench. I found it lacking in basic features like displaying the list of connections, databases, schemas, tables, etc. The whole reason I am using GUI is that I don't have to remember the database objects.

While any postgres GUI clients would work for running basic queries on redshift, things like IAM authentication, federated authentication require redshift JDBC drivers that I need to use. 

Since I am only an occasional user I needed a free tool (preferably open source) to do the job and am not looking to pay for the software.

My final set of requirements for the tool were:

1. Provides decent GUI.
1. Can use redshift JDBC drivers.
1. Can run on multiple platforms (mac, windows)
1. Free(Permissive enough licensing for me to use it for commercial purposes. I support customers making my use commercial.) or open source.

After some search and trying out a couple of clients I stumbled on DBeaver. I am not going to provide a comparison of multiple tools that I tried but will focus on [DBeaver](https://dbeaver.io) that met my requirements.

My take:

1. It is built on eclipse - so kinda heavy - but worked without any challenge. 
1. A generic SQL client that can connect to any database given the JDBC driver.
1. Works on mac, windows and linux.
1. It's open source (Apache license)

While my needs are not extreme and I have not tested DBeaver to its full extent, it could work for a heavy user too. Check it out. All the best.

