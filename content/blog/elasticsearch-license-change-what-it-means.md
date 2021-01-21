---
title: "Elasticsearch License Change and what it means for the community and you"
date: 2021-01-20T19:21:52-08:00
draft: false
image: images/blog/elasticsearch.jpg
tags: ["search", "elasticsearch", "license", "open source"]
author: Prabhat Sharma
type: post
---

Elastic changed the licensing terms for elasticsearch yesterday. It means that any new versions of elasticsearch will not be Apache 2.0 licensed, but [SSPL](https://www.mongodb.com/licensing/server-side-public-license) licensed.

What does it mean?

From https://www.elastic.co/blog/license-change-clarification

1. Our on-prem or Elastic Cloud customers will not be impacted.
1. The vast majority of our users will not be impacted.
1. The folks who take our products and sell them directly as a service will be impacted, such as the Amazon Elasticsearch Service.

There are mamny organizations who use elasticsearch for offering search services. Logz.io which uses elasticsearch for providing log storage and search service responded not so nicely in this [blog](https://logz.io/blog/open-source-elasticsearch-doubling-down/)

I personally have used elasticsearch in past and it's a fantastic piece of software. Sad to see the direction in which it is going.

In general you would want to go for a manged service that you can use and not have the headache of managing the infrastructure. But if you need to have your own clusters then you will have to look elsewhere.

So what are the options?

1. Amazon offers [Open Distro](https://opendistro.github.io/for-elasticsearch/), a fork of elasticsearch.
1. [Vespa](https://github.com/vespa-engine/vespa) written in Java
1. [Toshi](https://github.com/toshi-search/Toshi) written in Rust using [tantivy](https://github.com/tantivy-search/tantivy).
1. [Bayard](https://github.com/bayard-search/bayard) written in Rust using [tantivy](https://github.com/tantivy-search/tantivy).
1. [Sonic](https://github.com/valeriansaliou/sonic) written in Rust
1. [Blast](https://github.com/mosuka/blast) written in Go using [Bleve](https://github.com/blevesearch/bleve)
1. [Typesense](https://github.com/typesense/typesense) written in c++

In general I do not have great love for stuff written in Java, primarily because of huge requirements of JVM. And the non-JVM alternatives are really cool and and can be run with a fraction of resources if you don't need all the features of elasticsearch (A great many of us will not need all features)


> Disclaimer - I work for AWS. The views and opinions on this website are my own and may or may not align with AWS official stance.