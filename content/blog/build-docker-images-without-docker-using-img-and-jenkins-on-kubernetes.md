---
title: "Build Docker images without Docker using Img and Jenkins on Kubernetes"
date: 2019-08-12T11:40:36-07:00
draft: true
tags: ["kubernetes", "CICD", "Jenkins"]
author: Prabhat Sharma
type: post
---

<i>Note: I will be using an Amazon EKS cluster on AWS and using Amazon ECR for storing images. There will be minor differences for handling other repositories.</i>

In the [earlier post](../build-docker-images-without-docker-using-kaniko-jenkins-and-k8s) we learnt on how to to build a docker image using kubernete plugin in Jenkins on Kuberenetes. In this post we will look at how to build a docker image using [Img](https://github.com/genuinetools/img). We will follow the same steps as the [earlier post](../build-docker-images-without-docker-using-kaniko-jenkins-and-k8s) but will have a different pipeline script. 


{{<highlight groovy "linenos=table">}}
pipeline {
  agent {
    kubernetes {
      //cloud 'kubernetes'
      yaml """
kind: Pod
metadata:
  name: img
spec:
  containers:
  - name: img
    image: jessfraz/img
    imagePullPolicy: Always
    command:
    - cat
    tty: true
    volumeMounts:
      - name: docker-config
        mountPath: /home/user/.docker
  volumes:
    - name: docker-config
      configMap:
        name: docker-config
"""
    }
  }
  stages {
    stage('Build with Img') {
      environment {
        PATH = "/home/user/bin:$PATH"
      }
      steps {
        git 'https://github.com/prabhatsharma/sample-microservice'
        container(name: 'img') {
            sh 'wget https://amazon-ecr-credential-helper-releases.s3.us-east-2.amazonaws.com/0.3.1/linux-amd64/docker-credential-ecr-login'
            sh 'chmod +x docker-credential-ecr-login'
            sh 'mkdir ~/bin'
            sh 'mv docker-credential-ecr-login ~/bin/docker-credential-ecr-login'
            sh '''
            img build . -t 107995894928.dkr.ecr.us-west-2.amazonaws.com/sample-microservice:latest -t 107995894928.dkr.ecr.us-west-2.amazonaws.com/sample-microservice:vImg$BUILD_NUMBER
            '''
            sh ' img push 107995894928.dkr.ecr.us-west-2.amazonaws.com/sample-microservice:latest'
            sh ' img push 107995894928.dkr.ecr.us-west-2.amazonaws.com/sample-microservice:vImg$BUILD_NUMBER'
        }
      }
    }
  }
}
{{< / highlight >}}

<br>
Pay close attention from line 35 to 38 where we are downloading [Amazon ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper) and placing it in the container. We d