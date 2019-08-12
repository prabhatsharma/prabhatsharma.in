---
title: "Build Docker images without Docker - using Kaniko, Jenkins and Kubernetes"
date: 2019-08-08T02:09:13-07:00
draft: false
image: images/blog/k8s+jenkins+kaniko.png
tags: ["kubernetes", "containers", "docker", "kaniko", "jenkins", "CICD"]
author: Prabhat Sharma
type: post
---

<i>Note: I will be using an Amazon EKS cluster on AWS and using Amazon ECR for storing images. There will be minor differences for handling other repositories.</i>

Jenkins is a hugely popular build tool that has been around for ages and used by many people. With huge shift to Kubernetes as a platform you would naturally want to run jenkins on Kubernetes. While running Jenkins in itself on Kubernetes is not a challenge, it is a challenge when you want to build a container image using jenkins that itself runs in a container in the Kubernetes cluster. 

The process of running Docker-in-Docker (DIND), and setting it up is not very interesting not to mention the hacking that you need to do to achieve it.

An alternative would be [Kaniko](https://github.com/GoogleContainerTools/kaniko) which provides a clean approach to building and pushing container images to your repository.

In this post we will build a Jenkins pipeline that will be responsible for pulling code, building image and pushing image to Amazon ECR.

If you don't already have Jenkins installed then follow the steps in [this post](../installing-jenkins-on-kubernetes)

We will follow the below steps:

1. Create a configmap for docker configuration that will use ECR credential helper
2. Build a Jenkins pipeline

# Step 1: Create a configmap for docker configuration that will use ECR credential helper

Amazon ECR uses AWS IAM authentication to get docker credentials for pushing the images. [ECR crdenetial helper](https://github.com/awslabs/amazon-ecr-credential-helper) makes getting the credentials for pushing images easier. Setting up ECR crdenetial helper for Docker/Kaniko needs a configuration file. Let's go ahead and create a configuration file.

Create a configmap <b><i>docker-config.yaml</i></b>

{{<highlight yaml "linenos=table">}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: docker-config
data:
  config.json: |-
    {
      "credHelpers": {
        "123456789498.dkr.ecr.us-west-2.amazonaws.com": "ecr-login"
      }
    }
{{</highlight>}}

<br>
Replace 123456789498 with your AWS account number.

Run the below command to create the configmap.
You must install the configmap in the same namespace where jenkins is installed.

{{<highlight yaml>}}
kubectl -n jenkins apply -f docker-config.yaml
{{</ highlight>}}


# Step 2: Create a Jenkins pipeline to build and push the container image


Once you are logged in to Jenkins it's time to create a new Jenkins pipeline. Follow the steps:

#### 1. Create a <b><i>New Item</i></b>



<img src="/images/blog/jenkins-new-item.png" width="400px">

#### 2. Create a new <b><i>Pipeline</i></b>

<img src="/images/blog/jenkins-new-pipeline.png" width="800px">

#### 3. Place the pipeline script in the job

Now place the below script in the pipeline script section:

{{<highlight groovy "linenos=table">}}
pipeline {
  agent {
    kubernetes {
      //cloud 'kubernetes'
      yaml """
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug-539ddefcae3fd6b411a95982a830d987f4214251
    imagePullPolicy: Always
    command:
    - cat
    tty: true
    volumeMounts:
      - name: docker-config
        mountPath: /kaniko/.docker
  volumes:
    - name: docker-config
      configMap:
        name: docker-config
"""
    }
  }
  stages {
    stage('Build with Kaniko') {
      steps {
        git 'https://github.com/prabhatsharma/sample-microservice'
        container(name: 'kaniko') {
            sh '''
            /kaniko/executor --dockerfile `pwd`/Dockerfile --context `pwd` --destination=123456789498.dkr.ecr.us-west-2.amazonaws.com/sample-microservice:latest --destination=123456789498.dkr.ecr.us-west-2.amazonaws.com/sample-microservice:v$BUILD_NUMBER
            '''
        }
      }
    }
  }
}
{{< / highlight >}}

<br>
We are using a [sample microservice](https://github.com/prabhatsharma/sample-microservice) for which we will build an image and push it to ECR.
You must also have the <b><i>123456789498.dkr.ecr.us-west-2.amazonaws.com/sample-microservice</i></b> ECR repository created before running this pipeline.

We are using an older kaniko docker image (tag debug-539ddefcae3fd6b411a95982a830d987f4214251) as the latest kaniko docker image is not compatible with Jenkins Kubernetes plugin.

<br>

<img src="/images/blog/jenkins-pipeline-script.png" width="900px">


Now save the pipeline. You are all set up. Next you can click <b><i>Build Now</i></b> link to start the build.

<img src="/images/blog/jenkins-build-now.png" width="900px">

Once the build completes your screen should look like below 

<img src="/images/blog/jenkins-build-complete.png" width="900px">

and you should have a docker image in your repository:

<img src="/images/blog/ecr-image.png" width="900px">

You are all set !!!
