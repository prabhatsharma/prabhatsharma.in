---
title: "Reserving Compute Resources for System Daemons in Kubernetes using node-allocatable"
date: 2018-10-19T17:10:32-07:00
draft: false
tags: ["k8s", "kubernetes", "cgroup", "node-allocatable", "qos"]
author: Prabhat Sharma
type: post
image: images/blog/computer-chip.png
---

I was discussing resource management on k8s worker nodes with someone and they mentioned that they had faced a situation earlier where scheduler will schedule a lot of pods on the worker  node which would consume all of the node's CPU and memory leaving other system processes starved of resources, that ultimately leads the node to crash.

Kubernetes provides a feature to solve this problem called <b>Node Allocatable</b> that allows you to reserve resources for system daemons so that they are not starved of resources and continue to function well. Let's take a look at the concept and then how to implement them on your cluster.

<i style="color:red">Note: I will be using an EKS cluster on AWS but the concepts and steps should be similar on other cloud providers.</i>

Before we dig into the concepts let's run the below 2 commands:

<i style="color:blue">
1. $ kubectl get nodes
</i>

output:

<i style="color:blue"><pre>
NAME                                            STATUS   ROLES    AGE   VERSION
ip-192-168-191-215.us-west-2.compute.internal   Ready    <none>   48d   v1.10.3
ip-192-168-253-151.us-west-2.compute.internal   Ready    <none>   21h   v1.10.3
ip-192-168-69-9.us-west-2.compute.internal      Ready    <none>   48d   v1.10.3
</pre></i>

<i style="color:blue">
2. $ kubectl describe node ip-192-168-191-215.us-west-2.compute.internal
</i>

You will get a lot of information from this command. However let's take a look at the section that we are interested in:

<i style="color:blue"><pre>
...
Capacity:
 cpu:                2
 ephemeral-storage:  20959212Ki
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             7869640Ki
 pods:               29
 ...
</pre></i>

In light of above info we have to understand that pods can be scheduled to <b>Capacity</b> unless node-allocatable is being used. This feature uses linux [cgroups](https://en.wikipedia.org/wiki/Cgroups) to enforce resource limits if you are using cgroups driver which is what we will use here(another option is systemd).

We will do our analysis on a [m5.large](https://aws.amazon.com/ec2/instance-types/m5/) (2 vCPU, 8 GB RAM)

Let's define some terms:

1. Node capacity: Total capacity of the node in terms of CPU, memory, storage etc.
1. Allocatable: Total amount of resources available to scheduler for scheduling pods.

Now on this node we will need to run following:

1. System daemons - e.g. sshd, cron, etc
2. Kubernetes proesses - e.g. kubelet, container runtime, node problem detector, etc.
3. Pods provisioned by kubelet on the node

If we don't do anything kubelet will go ahead and use all the node capacity ( 2vCPU and 8 GB RAM) for provisioning pods. This will leave no resources for system daemons and kubernetes processes and may lead to them becoming unresponsive and crash.

In order for us to set aside resources for system daemons and kubernetes processes we will need to instruct kubelet to do so. The way to do it is by passing the following arguments to kubelet:

1. For kubernetes processes: --kube-reserved=[cpu=100m][,][memory=100Mi][,][ephemeral-storage=1Gi]
1. For system processes: --system-reserved=[cpu=100m][,][memory=100Mi][,][ephemeral-storage=1Gi]

You will also need to enforce node-allocatable by passing following argument:

- --enforce-node-allocatable=pods[,][system-reserved][,][kube-reserved]

Before we look at how to exactly implement this, there is one more thing that you could do. You would want to always have certain amount of free memory available other than system processes, kubernetes processes and pods, so that there is some wiggle room for adjustment during changes that happen during provisioning, since out-of-memory and filesystem storage shortage can render the node unavailable.

You could do this by setting up an eviction threshold parameter. Setting up this parameter leads to evicting pods when the set limit is breached.

- --eviction-hard=[memory.available<500Mi]

On an EKS cluster let's see how this would look like. ssh into the worker node and open the file /etc/systemd/system/kubelet.service file
Below is my kubelet systemd unit file. Lines in red are modified to achieve the desired effect:

<i style="color:blue"><pre>
1. ssh -i key.pem ec2-user@<public ip>
2. sudo vi /etc/systemd/system/kubelet.service
</pre></i>

and make the changes in red as marked below.

<pre><i style="color:blue">
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \
  --address=0.0.0.0 \ <i style="color:red">
  --enforce-node-allocatable=pods \ 
  --kube-reserved=cpu=1,memory=1Gi,ephemeral-storage=1Gi \
  --system-reserved=cpu=500m,memory=1Gi,ephemeral-storage=1Gi \
  --eviction-hard=memory.available<500Mi,nodefs.available<10% \ </i>
  --authentication-token-webhook \
  --authorization-mode=Webhook \
  --allow-privileged=true \
  --cloud-provider=aws \
  --cluster-dns=10.100.0.10 \
  --cluster-domain=cluster.local \
  --cni-bin-dir=/opt/cni/bin \
  --cni-conf-dir=/etc/cni/net.d \
  --container-runtime=docker \
  --max-pods=29 \
  --node-ip=192.168.191.215 \
  --network-plugin=cni \
  --pod-infra-container-image=602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/pause-amd64:3.1 \
  --cgroup-driver=cgroupfs \
  --register-node=true \
  --kubeconfig=/var/lib/kubelet/kubeconfig \
  --feature-gates=RotateKubeletServerCertificate=true \
  --anonymous-auth=false \
  --client-ca-file=/etc/kubernetes/pki/ca.crt

Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
</i></pre>


We would make the above changes to /etc/systemd/system/kubelet.service file and run following commands to reload.

<i style="color:blue"><pre>
1. sudo systemctl dameon-reload
2. sudo systemctl restart kubelet
</pre></i>

Let's see the impact of changes now.

<i style="color:blue"><pre>
Capacity:<i style="color:red">
 cpu:                2
 ephemeral-storage:  20959212Ki</i>
 hugepages-1Gi:      0
 hugepages-2Mi:      0<i style="color:red">
 memory:             7869640Ki</i>
 pods:               29
Allocatable:<i style="color:red">
 cpu:                500m
 ephemeral-storage:  19314749430</i>
 hugepages-1Gi:      0
 hugepages-2Mi:      0<i style="color:red">
 memory:             5260488Ki</i>
 pods:               29
</pre></i>

Look at the differences in cpu, ephemeral storage and memory under the sections <b>Capacity</b> and <b>Allocatable</b>.

Congrats!!! you have been able to set aside resources for system and kubernetes processes along with setting up eviction thresholds to prevent the node from becoming unavailable.

<hr>
References:

- [https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/](https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/)
- [https://en.wikipedia.org/wiki/Cgroups](https://en.wikipedia.org/wiki/Cgroups)


# Comments
<div id="commento"></div>
<script src="https://cdn.commento.io/js/commento.js"></script>
