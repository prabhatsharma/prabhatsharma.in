---
title: "How to make reads from mongodb efficient using replicas"
date: 2019-09-16T17:02:46-07:00
draft: false
tags: ["mongodb", "database"]
author: Prabhat Sharma
type: post
image: images/blog/mongodb.png
---

Generally you run mongodb in a cluster that has replicas. Together the replicas are part of a replicaset. Replicasets allow you to have fault tolerance and high availability for your mongodb. You generally have one **primary** and 2 or more **secondary** replicas in the cluster. Data is written to primary and it gets replicated to replicas. While you would always be writing to primary, you have the option to read from primary or replicas. When reading you can read from primary or secondary. There are certain considerations on when to use each of these. The way you make a selection is by specifying in the connection string when creating the connection to the database cluster.

A typical connection string to mongodb would look like:

> **mongodb://user:password@mongoserver:27017?readPreference=primaryPreferred&replicaSet=replicasetName**

Whether you want to read from primary or secondary, is specified in the connection string property readPreference. It can have following values:



| Read Preference Mode  | Description
| ----------------------| ------------------------------------------
| primary	              | Default mode. All operations read from the current replica set primary.
| primaryPreferred      | 	In most situations, operations read from the primary but if it is unavailable, operations read from secondary members.
| secondary             | 	All operations read from the secondary members of the replica set.
| secondaryPreferred    | In most situations, operations read from secondary members but if no secondary members are available, operations read from the primary.
| nearest               | Operations read from member of the replica set with the least network latency, irrespective of the member’s type.

<br>
You can find more information about readPreference in the [mongodb docs](https://docs.mongodb.com/manual/core/read-preference/)

If you are not reading immediately after creating the documents then you should use **secondary** or **secondaryPreferred**. You can also use **nearest** to improve performance.

I generally use **nearest** to improve performance.

Hope this helped you understand a little bit on how to make reads more efficient in your mongodb cluster.

