---
title: "Installing Jenkins on Kubernetes"
date: 2019-08-08T02:08:17-07:00
draft: false
image: images/blog/jenkins.png
tags: ["kubernetes", "containers", "docker", "jenkins", "CICD"]
author: Prabhat Sharma
type: post
---

In this post I will cover the steps to install Jenkins in a Kubernetes cluster. While Jenkins can be installed on standard VMs, if you are running a Kubernetes cluster then its much easier to install and run Jenkins in it. 

We will be using [Helm](../helm-tutorial-the-package-manager-for-kubernetes-part-1) to install Jenkins.

We will follow the below steps to get up and running:

1. Get the Jenkins values file for configuring our Jenkins installation
2. Install Jenkins
3. Access Jenkins


Let's rock 'n' roll:

# Step 1. Get the Jenkins values file for configuring our Jenkins installation

First get the Jenkins Helm values file for configuring our Jenkins installation.

wget https://raw.githubusercontent.com/helm/charts/master/stable/jenkins/values.yaml -O jenkins-values.yaml

Change 

{{<highlight yaml>}}
  serviceType: LoadBalancer
{{</ highlight>}}
to
{{<highlight yaml>}}
  serviceType: ClusterIP
{{</ highlight>}}

We don't want to expose Jenkins directly via a LoadBalancer and use an ingress instead (Not covered in this blog)

# Step 2. Install Jenkins

Run the below command:

{{<highlight shell>}}
helm install stable/jenkins --name=jenkins --namespace=jenkins -f jenkins-values.yaml
{{</highlight>}}

This will install jenkins in your cluster. 


# Step 3. Access Jenkins

To log on to Jenkins, let's get the credentials.

Get the password for jenkins admin user by running below command:

{{<highlight shell>}}
kubectl -n jenkins get secret jenkins -o=jsonpath='{.data.jenkins-admin-password}' | base64 --decode
{{</ highlight>}}

You can then log on to jenkins using the user <b><i>admin</i></b> and the password you retrieved.

You can now use port forwarding to access jenkins. Run the below command:

{{<highlight shell>}}
kubectl -n jenkins port-forward svc/jenkins 8080:8080
{{</ highlight>}}

Now you can head on to the http://localhost:8080 to access Jenkins
<img src="/images/blog/jenkins-login-page.png" width="800px">

In order for Jenkins to be accessible over the internet/intranet you can expose it using an ingress.

Congratulations!!!