---
title: "CKA Practice Test 2"
date: 2020-08-18T09:56:16-07:00
image: images/blog/cka.png
tags: ["kubernetes", "cka", "certification", "exam", "practice test"]
draft: false
author: Prabhat Sharma
type: post
---

2nd practice test for CKA exam preparation. First is at [CKA exam practice test 1](/blog/cka-practice-test-1)

1. Display all the pods sorted by start time
1. Create a pod that uses secrets
    1. Create a secret
    1. Pull secrets from environment variables
    1. Pull secrets from a volume
    1. Dump the secrets out via kubectl to show it worked
1. Create a job that runs every 3 minutes and prints out the current time.
1. Create a job that runs 20 times, 5 containers at a time, and prints "Hello parallel world"
1. Create a horizontal autoscaling group that starts with 2 pods and scales when CPU usage is over 50%.
1. Create a custom resource definition - CRD
	1. Display it in the API with curl
1. Create a networking policy such that only pods with the label access=granted can talk to it.
	1. Create a nginx pod and attach this policy to it. 
	1. Create a busybox pod and attempt to talk to nginx - should be blocked
	1. Attach the label to busybox and try again - should be allowed
1. Create a service that references an externalname.
	1. Test that this works from another pod
1. Create a pod that runs all processes as user 1000.
1. Create a namespace
	1. Run a pod in the new namespace
	1. Put memory limits on the namespace
	1. Limit pods to 2 persistent volumes in this namespace
1. Write an ingress rule that redirects calls to /foo to one service and to /bar to another
1. Write a service that exposes nginx on a nodeport
	1. Change it to use a cluster port
	1. Scale the service
	1. Change it to use an external IP
	1. Change it to use a load balancer
1. Deploy nginx with 3 replicas and then expose a port
	1. Use port forwarding to talk to a specific port
1. Make an API call using CURL and proper certs
1. Join a new node to cluster
1. Rotate certificates
1. Taint a node and un-taint it
1. Restart kubelet
1. Configure the cluster to use 8.8.8.8 and 8.8.4.4 as upstream DNS servers.
1. Create a pod with nginx and place a file using an init container that creates a simple index.html file with content - “created by init container”
1. You have a Container with a volume mount. Add an init container that creates an empty file in the volume. (the only trick is to mount the volume to 1. init-container as well)
1. Backup an etcd cluster
1. List the members of an etcd cluster
1. Find the health of etcd


