---
title: "Logging in Kubernetes using Elasticsearch: The easy way"
date: 2018-11-26T08:20:03-08:00
draft: false
tags: ["k8s", "kubernetes", "logging", "elasticsearch", "fluentd", "fluent-bit",]
author: Prabhat Sharma
type: post
image: images/blog/k8s-logging.png
---

In my conversations with various development teams I regularly come across this common question of how to do logging on kubernetes.

While there are existing solutions like EFK (elasticsearch, fluentd, kibana) stack, it takes good amount of effort for setting these up and making them work. I was wondering if I can provide some easy steps to people who just want to get started with logging in not so cumbersome and tedious way. 

So, let's look at how to set up "logging in kubernetes the easy way".

## Prerequisites

1. A running kubernetes cluster. You can setup one using kops, eks (on AWS), or GKE (on GCP)
1. Helm installed. If you don't already have it follow [this](/blog/helm-tutorial-the-package-manager-for-kubernetes-part-1/) tutorial to get up and running.

## fluent-bit

Before we start setting up our infrastructure, I chose this instead of using fluend directly was the fact that it enriches the metadata of logs by querying API server. It adds following to the logs:

1. POD Name
1. POD ID
1. Container Name
1. Container ID
1. Labels
1. Annotations

That is pretty neat to get out of the box.

## Installation

Below are the steps to have a basic installation that will get you up an running in 5 minutes. For production use you might want to modify various parameters of the helm charts (e.g. size of elasticsearch persistent volume claim. Default is 30 GB).


Create a namespace logs and install elasticsearch

{{< highlight shell>}}
$ helm install stable/elasticsearch --name=elasticsearch --namespace=logs
{{< / highlight >}}

Install fluent-bit and pass the elasticsearch service endpoint to it during installation. This chart will install a daemonset that will start a fluent-bit pod on each node. This is the workhorse of log collection. It will pick the logs from the host node and push it to elasticsearch. Elasticsearch service URL is http://elasticsearch-client:9200

{{< highlight shell>}}
$ helm install stable/fluent-bit --name=fluent-bit --namespace=logs --set backend.type=es --set backend.es.host=elasticsearch-client
{{< / highlight >}}

At this point you will have logs collecting in elastisearch. Now you will want to search logs. This is where you install kibana.

{{< highlight shell>}}
$ helm install stable/kibana --name=kibana --namespace=logs --set env.ELASTICSEARCH_URL=http://elasticsearch-client:9200
{{< / highlight >}}

Now you have everything setup. To reach the kibana dashboard make it available on your machine locally by forwarding the port.

{{< highlight shell>}}
$ kubectl -n logs port-forward svc/kibana 9080:443
{{< / highlight >}}

You should now be able to access kibana dashboard on your machine by pointing your browser at http://localhost:9080

You are all setup.

<p style="color:red;">
A word of caution. Do not expose kibana dashboard service yet using a service type of Loadbalancer or Ingress as it will open it to the world without any authentication. We will look at how to add authentication to kubernetes services in a future post.
</p>


