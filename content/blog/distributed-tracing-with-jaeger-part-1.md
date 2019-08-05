---
title: "Distributed Tracing With Jaeger Part 1"
date: 2018-10-16T00:11:22-07:00
tags: ["kubernetes", "helm", "jaeger", "opentracing", "tracing", "distributed tracing"]
author: Prabhat Sharma
type: post
image: images/blog/jaeger-logo.png
draft: true
---

For those of us dealing with microservices of decent complexity it is imperative to understand the flow of control and data in order to trace errors and debug the application. Jaeger can be used to provide distributed tracing functionality in microservice running in kubernetes.

![Jaeger Architecture](http://eng.uber.com/wp-content/uploads/2017/02/5-6-EngBlog-Distributed-Tracing-at-Uber.png)

<font size=2>Architecture reference at: [https://eng.uber.com/distributed-tracing/](https://eng.uber.com/distributed-tracing/)</font>

