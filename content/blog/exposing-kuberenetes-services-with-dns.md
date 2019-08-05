---
title: "Exposing Kuberenetes Services With DNS"
date: 2019-07-22T11:49:23-07:00
draft: true
tags: ["k8s", "kubernetes", "monitoring", "Prometheus", "Istio"]
author: Prabhat Sharma
type: post
---

Note: I am using an Amazon EKS cluster and will be using Route53 for configuration.

Exposing services in Kubernetes can be done by 2 ways. Either use a service of type of LoadBalancer or use an ingress. Let's take a look at each one.

### Service Type LoadBalancer

{{< highlight yaml>}}
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 8080
    targetPort: 8080
  type: LoadBalancer

{{< / highlight >}}

The above will create an AWS classic load balancer that can is configured for use only by this service. Your load balancer will be provided a CNAME that will look like <i>ab426524ba3ed11e9df421a6639b2fc7-1237582305.us-west-2.elb.amazonaws.com</i>. You service can now be accessed at the CNAME. You can also set Route53 to point to this CNAME. e.g. test.prabhatsharma.com can point to 







