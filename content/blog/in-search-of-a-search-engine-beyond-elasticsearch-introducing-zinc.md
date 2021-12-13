---
title: "In search of a Search Engine, beyond Elasticsearch: Introducing Zinc"
date: 2021-12-11T18:05:03-08:00
draft: false
image: images/blog/detective.png
tags: ["Elasticsearch", "OpenSearch", "fulltext", "full text", "search engine", "go", "golang", "Zinc", "Zincsearch", "Zinc search"]
author: Prabhat Sharma
type: post
---
# Introduction

A search engine is a software that can search for any text in the data that has been indexed for full text. While there are public search engines like Google and Bing, we are not talking about them in this blog, but of softwares that would allow you to search for text in your own data. Think of a this kind of search engine software as google or bing but just for your own data.

# Why Zinc?

I was looking for a simple software to index my logs that did not require huge amounts of resources and after a decent amount of research, I could not find something that could do it. 

What was I looking for:

1. Small resource requirments.
1. On-disk search (Not in-memory).
1. Easy to setup and operate.
1. Schema-less indexes.
1. Good GUI for exploring data.

None of the existing solutions today provide that. I have explored many and later in this blog I have provided a list of some main street products that I looked at and also some softwares on the fringes created by individuals as hobby/side projects hoping to use them or build more on top of them. I looked at these before I figured out that I will have to build something new to meet my above needs.

I also looked at Loki from Grafan labs which is a fantastic sollution, but it does not have full text search capability and requires grafana as well.

I tried working with typesense, sonic and toshi and extend them trying to develop something with them as well, but it did not work.

All of this lead to birth of [Zinc](https://github.com/prabhatsharma/zinc).

# What is Zinc?

[Zinc](https://github.com/prabhatsharma/zinc) is a search engine for doing full text search on documents. It is open source and built in Go. Instead of building the indexing engine from scratch, [Zinc](https://github.com/prabhatsharma/zinc) is built on top of bluge, an excellent indexing library. Some features of [Zinc](https://github.com/prabhatsharma/zinc):

1. Schema-less indexing
1. Low resource utilization
1. Easy to use lightweight GUI
1. Builtin authentication
1. Simple APIs for programmatic usage
1. Compatibility with Elasticsearch APIs (Ingestion - single record and bulk APIs) for applications that want to migrate from Elasticsearch to Zinc.

Some features on roadmap:

1. High availability
1. Distributed reads and writes
1. Geosptial search.
1. Index storage in memory
1. Index storage in s3
1. Hit me up ([Create an issue on github](https://github.com/prabhatsharma/zinc/issues/new)). Open to suggestions.


---

Now a little bit on the search products in market for those who do not have a background in search. We will start with Elasticsearch, the most popular search engine product.

All of the below search engines create [inverted indexes](https://en.wikipedia.org/wiki/Inverted_index) for searching data. Lucene was the earliest popular library (First released in 1999) that brought this kind of indexing to masses and Elasticsearch really made it popular.

# What is Elasticsearch/OpenSearch?

Elasticsearch is a search engine created in late 2000 and backed by Elastic (Incorporated in 2012) that develops and promotes the product. It also provides hosted Elasticsearch service.

Elasticsearch is used by organizations of all sizes for their search needs. In my personal experience I have seen majority of technology companies use Elasticsearch for storing and searching their logs. Elasticsearch is also the backbone of many SaaS logging services and services like graylog, logdna, loggly, logz.io, and more.

In January, 2021 elastic changed the licensing of Elasticsearch from Apache 2.0 to SSPL (A non OSI approved open source license). As a result AWS, logz.io and others created a fork of the last available Apache 2.0 open source version of Elasticsearch (version 7.10.2).

OpenSearch is open source (Apache 2.0) and is also offered as a hosted service (Amazon OpenSearch).

I have found Elasticsearch/OpenSearch to be an excellent piece of software which does the job of indexing full text fantastically well for your data. When I first encounterd it, it was like I can really do full text search for my own data and don't have to worry about WHERE clause like in SQL. 

I had grown to love it. I had also recommended it to many of my customers. However I also figured out its resource requirements. It is quite heavy. It needs a minimum of 0.5 GB  RAM to just start and may require multiple giga bytes of RAM to function well, owing to its JVM usage. I have slight dislike for stuff built in Java primarily due to JVM resource requirements. Also there are many configuration parameters that you will need to learn in order to leverage it well.

One of the primary use cases that I had which I wanted to solve was to search gigabytes of logs fast along with some other full text search. I had evaluated loggging services like logdna, papertrail, logrhythm, logz.io, etc... and for personal projects they are a bit expensive. Amazon cloudwatch with log insights is a good alternative as its pay-as-you-go like logdna. I was also looking at a decent self hosted open source solution.

Let's look at what is available beyond Elasticsearch/OpenSearch and what I found was 2 categories of full text search engines:

# Types of search engines 

One of these is used by applications for super fast search (in-memory search) and other for large amounts of data on disk (on-disk search which is still fairly fast).

## 1. Type 1 - In memory search engines

These search engines store the indexes in memory making searches super fast. Algolia, Meilisearch and typsesnse are good software/services in this category. Instant search (as you type or typeahead) is a popular use case for this kind of search engines. These provide superfast sub 50 ms responses and are excellent choices when you are building an application that required search on realitively small amounts of data (Not several gigabytes like logs but still millions of records). 

Log searching is not really a good use case for these search engines as everything gets loaded in memory and you will need huge searvers fast. These have their niche though. 

## 2. Type 2 - On disk search engines

Some examples in this category are Elasticsearch/OpenSearch, manticore, sphinx. This category of search egines searches for data on huge amounts of data on disks (Can be multiple terabytes). These are not as fast in terms of responses but still pretty fast for a lot of use cases. A decent setup can get you searches over several gigabytes of data in under 100 ms, which is pretty good for a lot of applications.  

Lets dive deeper into each of these search engines.

We will first cover in-memory serach engines

## Type 1 - In memory search engines:

### 1. Algolia

Fantastic search service with a lot of popular use cases and a lot of users. Its available only as a service and you can't host it on your own servers. Pricing is based on number of records and amount of searches made and storing huge amounts of data is cost prohibitive for most scenarios. It has a lot of connectors that can make it easily puggable in your application. Algolia has also created a javascript library called instantsearch.js which makes it easier to develop UI in web apps.


### 2. Typesense

[Typesense](https://github.com/typesense/typesense) is an open source (AGPL) search engine created from scratch in c++ . It's very fast and does not consume a lot of resources. Availability of docker images for self hosted scenarios is fantastic. It can also be installed in HA mode in kubernetes using kustomize manifests that I created. It is super easy to setup typesense and is highly performant. It uses raft for HA. Typesense also provides a fully managed cloud service.

### 3. Meilisearch

Meilisearch is another open source search engine written in rust which was built using algolia as inspiration. It is very similar to typesense but does not have HA mode yet. So if you are looking for a highly available resilient service meilisearch is not going to cut it (just not yet).


## Type 2 - On Disk search engines:

### 1. Elasticsearch/OpenSearch

[Elasticsearch/OpenSearch](https://github.com/OpenSearch-project/OpenSearch) is the most popular search engine in this category. Elasticsearch/OpenSearch is built on top of Apache Lucene which is a search engine library written in Java. It can run in HA mode and people have run clusters that have 100+ nodes. 

### 2. Apache Solr

[Apache Solr](https://github.com/apache/solr) is also built on top of Lucene with features coparable to Elasticsearch. It also makes use of Apache Tika to extract the documets like .doc and .pdf and index them. In the initial days a strict schema was required but not anymore. So if you are looking for indexing file documents (.doc, xls, pdf, ...) then Apache solr is the best choice out there. Provides HA mode for reliable operations. 

### 3. Sphinx

[Sphinx](https://github.com/sphinxsearch/sphinx) an open source (GPL 2) and is written in c++. It is kind of partially open source as at this point in time an older version (2.0) is available open souce, however the latest version 3 is closed source. 

### 4. Manticore

[Manticore](https://github.com/manticoresoftware/manticoresearch) written in c++ is an nother open source (GPL 2) search engine that has an intersting approach of using SQL first for search. It can speak SQL over HTTP or MySQL protocol. Provides HA mode through synchronous replication.

### 5. Sonic

[Sonic](https://github.com/valeriansaliou/sonic) written in rust is another open source (MPL) search engine. The notable difference compared to other search engines is that it does not store the whole document that was indexed. When you search, it will return you the ID of the document that you must use to fetch the whole document from another data store. This necessitates need for at least one more data store to keep the actual data. This may or may not be a great scenario depending on your use case. If you already have the data in another store like MySQL/Postgres/DynamoDB then sonic is great, however if you are looking to ingest data directly into sonic then you have a problem and sonic is not going to work for you.

Another difference from rest of the search-engines is that Sonic does not provide an http interface. It provides a sonic protocol that can be used for interacting with sonic. Client libraries are available for multiple languages. 

### 6. Quickwit

Quickwit is based on tantivy and shares the good things (high performance) and challenges of tantivy (strict schema requirement). It also stores its data on s3 decoupling storage and compute which is kinda nice.


# On the fringe

These are small hobby side projects by individuals appearing to be primarily developed for learning.

### Toshi

[Toshi](https://github.com/toshi-search/Toshi) is a search engine developed on top of tantivy and as a result ahs same strengths and weaknesses of tantivy - manily good speed and strict schema.

### Bayard

[Bayard](https://github.com/bayard-search/bayard) built on top of tantivy. Similar as Toshi.

### Blast

[Blast](https://github.com/mosuka/blast) built on top of bleve and is distributed.

### Riot

[Riot](https://github.com/go-ego/riot) is now archived.


---

Now let's move on to the next stage of indexing libraries.

# Indexing libraries

A little note on indexing libraries. Remember that you can't use any of these off the shelf as these are libraries and not really applications. And you can generally use these only (not always but mostly) in the languages these are written.

## Java

[Lucene](https://lucene.apache.org/) is the most popular java library which provides indexing capabilities. People have been using it directly in their java applications. Elasticsearch and Apache Solr use Lucene at its core. Lucene does not enforce strict schema.

## Rust

[Tantivy](https://github.com/tantivy-search/tantivy) is pretty fast indexing library which requires strict schema. Strict schema requirement may be a problem for some applications.

## Go

[Bleve](https://blevesearch.com/) was created at couchbase and is pretty popular library.

[Bluge](https://blugelabs.com/) is created by Marty, the creator of Bleve and is the successor of Bleve. If you are starting new projects then you should start with Bluge. Bluge is very simple to use and has good set of features like disk based and in-memory indexes which others lack. Coupled with very low resource requirements Bluge is a fantastic choice for most applications.

## C++

[Pisa](https://github.com/pisa-engine/pisa)

[Xapian](https://xapian.org/)

# Conclusion

So here we go. We saw a host of search engines that you can use and why I built Zinc. 

