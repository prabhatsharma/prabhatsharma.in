---
title: "Understanding Zookeeper by Doing"
date: 2020-01-29T07:30:47-08:00
draft: false
tags: ["k8s", "kubernetes", "zookeeper", "kafka", "distributed systems"]
author: Prabhat Sharma
type: post
image: images/blog/zookeeper.jpg
---

Software ecosystem of distrubuted systems is vast and each of the pieces do a specific task. Many a times you will find many systems that provide similar functionality.

Let's take a look at the problem of distributed coordination today, and one of the most popular systems to help solve it is zookeeper. Part of the hadoop ecosystem, zookeeper is very popular. Let's understand what it is and how it works.

At its core zookeeper is kind of a file system that has nodes and nodes store data. You can watch the changes to the nodes and take appropriate actions. Generally you would use zooker when you are building a distributed system that has multiple nodes and they need to coordinate with each other.

First thing we need to do is to install zookeeper. You can follow the official guide at https://zookeeper.apache.org/doc/r3.5.5/zookeeperStarted.html or you can follow the below steps to install zookeeper on your kubernetes cluster.

When trying out new stuff I like to use kubernetes as its easy to install prepackaged software using helm charts or operators. I have an EKS cluster running on AWS. If you would like to use kubernetes and want to spin up an EKS cluster you can create on using the command

{{< highlight shell>}}
eksctl create cluster --managed
{{< / highlight >}}

Head on to https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html to know more about eksctl


I will install zookeeper using [helm](https://helm.sh/) 3.

search for zookeeper in helm repository using 

{{< highlight shell>}}
helm search repo zookeeper
{{< / highlight >}}

Output:
<pre>
NAME                	CHART VERSION	APP VERSION	DESCRIPTION
incubator/zookeeper 	2.1.3        	3.5.5      	Centralized service for maintaining configurati...
incubator/kafka     	0.20.8       	5.0.1      	Apache Kafka is publish-subscribe messaging ret...
stable/kafka-manager	2.2.0        	1.3.3.22   	A tool for managing Apache Kafka.
</pre>

helm 3 installations are stored in namespaces. Lets crreate a namespace for zookeeper and switch to it.

{{< highlight shell>}}
kubectl create namespace zookeeper
{{< / highlight >}}

{{< highlight shell>}}
kubectl config get-contexts
{{< / highlight >}}

<pre>
CURRENT   NAME                                                  CLUSTER                                               AUTHINFO                                              NAMESPACE
*         prabhat@basic3.us-west-2.eksctl.io                    basic3.us-west-2.eksctl.io                            prabhat@basic3.us-west-2.eksctl.io                    default
          prabhat@f1.us-east-2.eksctl.io                        f1.us-east-2.eksctl.io                                prabhat@f1.us-east-2.eksctl.io
          prabhat@ireland14.eu-west-1.eksctl.io                 ireland14.eu-west-1.eksctl.io                         prabhat@ireland14.eu-west-1.eksctl.io
</pre>


{{< highlight shell>}}
kubectl config set-context prabhat@basic3.us-west-2.eksctl.io  --namespace=zookeeper
{{< / highlight >}}

{{< highlight shell>}}
helm install zookeeper incubator/zookeeper
{{< / highlight >}}

It will take a couple minutes and you will have a stateful application with 3 pods will be running.

{{< highlight shell>}}
kubectl get pods
{{< / highlight >}}

<pre>
NAME          READY   STATUS    RESTARTS   AGE
zookeeper-0   1/1     Running   2          3m
zookeeper-1   1/1     Running   1          2m
zookeeper-2   1/1     Running   0          1m
</pre>

Let's look at the service created for zookeeper

{{< highlight shell>}}
kubectl get services
{{< / highlight >}}

<pre>
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
zookeeper            ClusterIP   172.20.83.20   <none>        2181/TCP                     3m
zookeeper-headless   ClusterIP   None           <none>        2181/TCP,3888/TCP,2888/TCP   3m
</pre>

You can connect your laptop to the cluster using openvpn for easy development. Find details [here](https://prabhatsharma.in/blog/how-to-connect-to-kubernetes-cluster-resources-using-openvpn-for-local-development/ )

Now you can run the below code and it will show you the structure of information stored in zookeeper.

<script src="https://gist.github.com/prabhatsharma/5e20e905bc1da526c5c7c9c266a46949.js"></script>

sample output of ready.py

<pre>
/zookeeper
/zookeeper/config
/zookeeper/quota
/aws
/aws/cloudwatch
/aws/ec2
/aws/ec2/ebs
/aws/ec2/ebs/gp2
/aws/ec2/ebs/st1
/aws/ec2/ebs/io1
/base
/base/test01
</pre>

You can store upto 1 MB of data in the nodes. You also have the option of watching the particular nodes to benotified whenever they change or a child is added to them. Watching is what enables distributed coordination in great part.

In order to create a new node you can run the below code:

<script src="https://gist.github.com/prabhatsharma/68baaa1af601bd33e456075ebf3db7f6.js"></script>

After running the write script you can run the read script again to see the changes or make modifications to it to watch the nodes. 

This ends short experiment on zookeeper.

**Bonus** : [etcd](https://github.com/etcd-io/etcd) has been real popular recently for distributed coordination. If you are starting a new project you would want to use etcd instead of zookeeper. Its written in go and is much easier to use.

