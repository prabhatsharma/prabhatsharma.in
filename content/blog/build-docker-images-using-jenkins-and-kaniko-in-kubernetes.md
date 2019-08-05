---
title: "Build Docker Images Using Jenkins and Kaniko in Kubernetes"
date: 2019-08-04T15:36:15-07:00
draft: true
image: images/blog/dbeaver-small.png
tags: ["k8s", "kubernetes", "containers", "docker", "kaniko", "unprivileged"]
author: Prabhat Sharma
type: post
---


Get the values file

wget https://raw.githubusercontent.com/helm/charts/master/stable/jenkins/values.yaml -O jenkins-values.yaml

Change 

  serviceType: LoadBalancer
to
  serviceType: ClusterIP

Install additional plugins

  installPlugins:
    - kubernetes:1.18.1
    - workflow-job:2.33
    - workflow-aggregator:2.6
    - credentials-binding:1.19
    - git:3.11.0
    - amazon-ecr:1.6


helm install stable/jenkins -f jenkins-values.yaml --name=jenkins


kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=csanchez --docker-password=mypassword --docker-email=john@doe.com


kubectl create configmap docker-config --from-file=config.json https://raw.githubusercontent.com/prabhatsharma/kaniko-sample/master/config.json

