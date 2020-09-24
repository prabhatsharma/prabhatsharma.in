---
title: "CKA Practice Test 1"
date: 2020-08-18T09:55:16-07:00
image: images/blog/cka.png
tags: ["kubernetes", "cka", "certification", "exam", "practice test"]
draft: false
author: Prabhat Sharma
type: post
---

More than 2 years ago when I passed CKA, there were fewer resources available for me to study. I had to create a lot of resources myself during my cert preparation. During many of the certification exams that I have taken over a period I have realized that having a set of of test questions is incredibly helpful. I am posting the below practice exam questions that will be helpful to those aspiring to pass CKA. 

Many of these questions have been sourced from internet, and many of these have been written by me. There are 2 sets of practice tests that have some of the overlapping questions.

I would recommend that you practice these in a compressed timeline (preferably finish them in 1.5 Hrs as opposed to 3 Hrs) at your home. Idea is that, if you are able to finish the exam in 1.5 Hrs at your home you will be able to finish the exam in 3 Hrs an a much more tense situation when you are under pressure.

Here is the first set:

1. Create a node that has an SSD and label it as such. 
    1. Create a pod that is only scheduled on SSD nodes.
1. Create 2 pod definitions: the second pod should be scheduled to run anywhere the first pod is running - 2nd pod runs alongside the first pod.
1. Create a deployment running nginx version 1.12.2 that will run in 2 pods
    1. Scale this to 4 pods.
    1. Scale it back to 2 pods.
    1. Upgrade this to 1.13.8
    1. Check the status of the upgrade
    1. How do you do this in a way that you can see the history of what happened?
    1. Undo the upgrade
    1. Expose the service on port 80
1. Create a pod that uses a scratch disk.
    1. Change the pod to mount a path on the host.
1. Taint a node and run a Jenkins Pod on that specified node only.
1. Create a pod that has a liveness check
1. Use the utility nslookup to look up the DNS records of the service and pod.
1. Find which Pod is taking max CPU
1. List all PersistentVolumes sorted by their name
1. Create a daemon set
	1. Change the update strategy to do a rolling update but delaying 30 seconds between pod updates
1. Create a static pod
1. Create a busybox container without a manifest. Then edit the manifest.
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
1. Create a service that references an externalname -  https://api.github.com/users/prabhatsharma
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


2nd set is at [CKA exam practice test 2](/blog/cka-practice-test-2)

Feel free to add any questions in the comment section that you have created or have found in the wild.


