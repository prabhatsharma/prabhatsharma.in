---
title: "RED Monitoring With Istio and Prometheus"
date: 2019-07-21T22:50:19-07:00
draft: false
image: images/blog/prometheus.png
tags: ["k8s", "kubernetes", "monitoring", "Prometheus", "Istio"]
author: Prabhat Sharma
type: post
---

In this blog post we will discuss [RED method](https://www.weave.works/blog/the-red-method-key-metrics-for-microservices-architecture/) that I really like in terms of simplicity by which it explains the state of an application. We will also discuss how to cpature RED metrics for your application running in kubernetes. Primarily we need to capture 3 things

- (Request) Rate - the number of requests, per second, you services are serving.
- (Request) Errors - the number of failed requests per second.
- (Request) Duration - distributions of the amount of time each request takes.

In a kubernetes environment, a great way to capture metric is setting up a service mesh. Assuming you have set up istio, how do you get the RED metrics? I will be using a [sample ecommerce application](https://github.com/prabhatsharma/ecommerce-microservices) that I have built for the purpose of this exercise.

Istio provides a set of [default metrics](https://istio.io/docs/reference/config/policy-and-telemetry/metrics/) that we can use without setting up any additional specific configuration. These are:

1. Request Count (istio_requests_total): This is a COUNTER incremented for every request handled by an Istio proxy.
1. Request Duration (istio_request_duration_seconds): This is a DISTRIBUTION which measures the duration of requests.
1. Request Size (istio_request_bytes): This is a DISTRIBUTION which measures HTTP request body sizes.
1. Response Size (istio_response_bytes): This is a DISTRIBUTION which measures HTTP response body sizes.

Below are some examples. Make sure to modify metrics selectors in time series for your own workload.

## Request Rate

We will get rate of istio_requests_total for last 30 minutes at 15 seconds resolution

{{< highlight shell>}}
rate(istio_requests_total{source_workload_namespace="ecommerce", destination_service_namespace="ecommerce",source_app="product",destination_app="recommendation",reporter= "source"}[30m:15s])
.
{{< / highlight >}}

## Errors

We can query http status codes for all the requests to get errors

{{< highlight shell>}}
sum(rate(istio_requests_total{source_workload_namespace="ecommerce"}[1m])) by (response_code, source_app)
.
{{< / highlight >}}

## Duration

You get the duration of each request by rate(istio_request_duration_seconds_sum)[1m]/rate(istio_request_duration_seconds_count)[1m]


{{< highlight shell>}}
avg(rate(istio_request_duration_seconds_sum{source_workload_namespace="ecommerce", destination_service_namespace="ecommerce",source_app="product",destination_app="recommendation",reporter= "source"}[1m])/rate(istio_request_duration_seconds_count{source_workload_namespace="ecommerce", destination_service_namespace="ecommerce",source_app="product",destination_app="recommendation", destination_version= "v2",reporter= "source",destination_version="v2"}[1m]))
.
{{< / highlight >}}



