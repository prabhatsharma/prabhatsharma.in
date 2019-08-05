---
title: "Installing Airflow on Kubernetes Using Operator"
date: 2019-07-28T15:26:08-07:00
draft: false
image: images/blog/airflow-logo.jpeg
tags: ["k8s", "kubernetes", "containers", "docker", "airflow", "helm", "data engineering"]
author: Prabhat Sharma
type: post
---

<h3 style="color:lightgrey">Operator - “A Kubernetes Operator is an abstraction for deploying non-trivial applications on Kubernetes. It wraps the logic for deploying and operating an application using Kubernetes constructs.” –Richard Laub, staff cloud engineer at Nebulaworks </h3>

<i style="color:red">
Note: I will be using an EKS cluster on AWS. You could use the same steps on other cloud providers too.
</i>

Well created [Kubernetes Operators](https://coreos.com/operators/) pack a lot of power and help run and manage stateful applications on kubernetes. We had earlier seen how to [install airflow on kubernetes using helm charts](../installing-aiflow-on-kubernetes). While helm charts help you get started fast, they may not be suitable for day 2 operatios like:

1. Upgrades
1. Backup & restore
1. Auto recovery
1. Automatic/On-demand scalability
1. Configuration management
1. Deep insights

Let's find how to install airflow on kubernetes using airflow operator.

<h2>1. Get the operator</h2>

{{< highlight shell>}}
git clone https://github.com/GoogleCloudPlatform/airflow-operator
{{< / highlight >}}


<h2>2. Install CRDs</h2>

{{< highlight shell>}}
kubectl apply -f config/crds
kubectl apply -f hack/appcrd.yaml
{{< / highlight >}}

<h2>3. Build operator docker image</h2>

{{< highlight shell>}}
# First we need to build the docker image for the controller
# Set this to the name of the docker registry and image you want to use
export IMG=hiprabhat/airflow-controller:latest 

# Build and push
docker build . -t $IMG
docker push ${IMG}
{{< / highlight >}}

<h2>4. Update docker image in config/manager_image_patch.yaml</h2>

Update the image

{{< highlight yaml "linenos=table,linenostart=6,hl_lines=6">}}
spec:
  template:
    spec:
      containers:
      # Change the value of image field below to your controller image URL
      - image: hiprabhat/airflow-controller:latest
        name: manager
{{< / highlight >}}

<br>

<h2>5. Install Airflow</h2>


{{< highlight shell>}}
# deploy base components first
kubectl apply -f hack/sample/mysql-celery/base.yaml
{{< / highlight >}}

You can specify the source of DAGs in the <i>hack/sample/mysql-celery/cluster.yaml</i> file.

{{< highlight yaml>}}
  dags:
    subdir: "airflow/example_dags/"
    git:
      repo: "https://github.com/apache/incubator-airflow/"
      # setting once to false allows the DAGs to be refreshed every 5 minutes
      once: false
{{< / highlight >}}



Now its time to deploy the airflow components. 

{{< highlight shell>}}
# after 30-60s deploy cluster components 
# using celery + git as DAG source
kubectl apply -f hack/sample/mysql-celery/cluster.yaml
# port forward to access the UI
kubectl port-forward mc-cluster-airflowui-0 8080:8080
{{< / highlight >}}


![AIRFLOW DAG PAGE](/images/blog/airflow-using-operator.png =250x100)
airflow-using-operator.png

<img src="/images/blog/airflow-using-operator.png" width="1024">


In order to setup authentication, follow the steps in the <a href="../installing-aiflow-on-kubernetes">earlier blog</a>


