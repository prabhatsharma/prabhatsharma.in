---
title: "How I passed Certified Kubernetes Administrator exam on first attempt"
date: 2018-10-03T23:07:58-07:00
image: images/blog/cka.png
tags: ["kubernetes", "cka", "certification", "exam"]
draft: false
author: Prabhat Sharma
type: post
---


I have been working for past couple of months on kubernetes and advising people on how to implement best practices using kubernetes for building applications. I wanted to test my knowledge and figured I should take the CKA exam to validate my knowledge of things. I began preparing about one and a half months ago for the certification and found its preparation to be as hard as AWS SA Pro exam which is considered to be one of the difficult certifications.

CKA is different from other certification exams that I have attempted before as it does not have a set of multiple choice questions that need to be answered. It consists of 24 tasks that need to be completed in 3 hours on a couple of real kubernetes clusters.

Below I will lay out the steps that I followed to get prepared that can help CKA aspirants to achieve the certification. I can't share the questions due to the confidentiality agreement but I can certainly share the tricks I used that helped me.

For covering the basics of kubernetes I took the [Kubernetes on Cloud](https://www.udemy.com/kubernetes-cka-on-cloud/learn/v4/overview) course on udemy . This was super beneficial and helped me get the breadth of knowledge on kubernetes. 

Next, I followed the CNCF [curriculum](https://github.com/cncf/curriculum) and tried to practice each of the items mentioned there. A good resource to follow all the items are at [Walid Shaari's github](https://github.com/walidshaari/Kubernetes-Certified-Administrator) repo.

Go ahead and watch the following videos:

1. [Kubernetes for Sysadmins](https://www.youtube.com/watch?v=HlAXp0-M6SY) to understand what problems kubernetes solves and how it does them.
2. [Life of a packet](https://www.youtube.com/watch?v=0Omvgd7Hg1I) to understand the internal workings of kubernetes.

Learn kubernetes the hard way - One of the first things to do was to set up a cluster on which I can practice. I initially used kubeadm for setting up the cluster. It worked well but did not teach me much. You should stay away from kubeadm if you are preparing for CKA. I needed to have full control of master and worker nodes which meant that I could not use a managed kubernetes service provided by a cloud provider. After some initial research, I found that kelsey hightower's [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) is a very good resource for learning the internals of kubernetes. The only problem with it was that it was built to run on GCP which I didn't want to use as I was super comfortable with AWS. I googled for AWS ported versions of it but did not find any that I liked. So I took some time and ported it to AWS. If you are an AWS guy you can access it at [Kubernetes the hard way on AWS](https://github.com/prabhatsharma/kubernetes-the-hard-way-aws). I practiced setting up clusters a couple of times using this approach to get a handle on the various components of kubernetes.

Learn about systemd. You must understand on how to build and modify systemd unit files. you must be comfortable in using systemctl to start, stop and restart services. Essentially it will boil down to 3 commands after creating/modifying unit files.

1. Create/modify systemd unit files 
2. systemctl daemon-reload
3. systemctl enable < service name >
4. systemctl start < service name>

service names would be etcd, kubelet, kube-proxy, kube-apiserver, kube-controller-manager, kube-scheduler

Kubernetes the hard way teaches you mostly all you need to learn about systemd but some additional learning would be great.

Be comfortable in using vi. The shortcuts that are going to be handy are: 

1. dd - delete the current line
2. dG - delete everything below the current line

Others told me to be comfortable in using tmux but I did not really find it to be of use during the exam.

Try the [CKA practice environment](https://github.com/arush-sal/cka-practice-environment) by Arush from kubernauts. While this does not totally mimic the environment it is good to understand what you will be getting.

Improve your speed by doing exams of 3 hours where you are solving 24 questions. Try to gain speed doing these things as it will be very crucial.

Now let's understand how we can be fast. Go the imperative way as much as you can as its going to be much faster than being declarative. 
You will be typing a lot of kubectl during the exam. A nice little trick that you can use to speed this up is set an alias

{{< highlight shell>}}
$ alias k=kubectl
{{< / highlight >}}

After this you can simply use the commands, like

1. k get nodes
2. k get pods

See !! this is so much better :-)

To create an nginx pod, instead of starting with a yaml file just run the following:

{{< highlight shell>}}
$ k run nginx --image=nginx --restart=Never
{{< / highlight >}}

To create a deployment with 2 replicas:

{{< highlight shell>}}
$ k run nginx --image=nginx --replicas=2
{{< / highlight >}}

In some cases, you will need to add specifics to a pod like adding a volume. In that case, you cannot rely solely on imperative commands. However imperative commands are still a good starting point for that. Let's look at this:

{{< highlight shell>}}
$ k run nginx --image=nginx --restart=Never --dry-run -o yaml
{{< / highlight >}}

will give following output that you can use as base.

{{< highlight yaml>}}
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    imagePullPolicy: IfNotPresent
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Never
status: {}
{{< / highlight >}}

To save the above output to a file just redirect it like this.

{{< highlight shell>}}
$ k run nginx --image=nginx --restart=Never --dry-run -o yaml > nginx-pod.yaml
{{< / highlight >}}

To see the options during the exam on how to use the imperative commands just run the following command:

{{< highlight shell>}}
$ k run
{{< / highlight >}}

This will show the help. Help will have several examples of creating a pod, deployment, job, scheduled job etc which you could simply copy. Be familiar with the options by practicing them.

I also joined CKA channel for kubernauts where aspirants hangout and are facilitated by good guys from kubernauts. You might want to join this [channel](https://kubernauts.slack.com)