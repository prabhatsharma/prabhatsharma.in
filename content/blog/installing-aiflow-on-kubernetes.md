---
title: "Installing Airflow on Kubernetes"
date: 2019-02-01T07:14:36-08:00
draft: false
image: images/blog/airflow-logo.jpeg
tags: ["k8s", "kubernetes", "containers", "docker", "airflow", "helm", "data engineering"]
author: Prabhat Sharma
type: post
---

Data engineering is a difficult job and tools like airflow make that streamlined. Let's take a look at how to get up and running with airflow on kubernetes.


# Prerequisites

1. A kubernetes cluster - You can spin up on [AWS](https://aws.amazon.com/eks/), [GCP](https://cloud.google.com/kubernetes-engine/), Azure or digitalocean or you can start one on your local machine using [minikube](https://kubernetes.io/docs/setup/minikube/)
2. Helm - If you do not already have helm installed then follow [this](../helm-tutorial-the-package-manager-for-kubernetes-part-1) tutorial to get it installed 

# Installing airflow using helm

## 1. Easy way

{{< highlight shell>}}
helm install stable/airflow
{{< / highlight >}}

This will install airflow with default settings and a random release name. You are up and running with basic installation.

Congratulations!!!

## 2. Sophisticated way

Chances are that for anything serious you would want to make changes to default installation.

We will make following changes to make our airflow installation useful in a n enterprise setting:

1. Create a namespace
1. Change the source of DAG files in the helm chart
1. Set up Active Directory authentication for airflow (Optional)

Let's expand each of the above steps

### 2.1 Create a namespace

{{< highlight shell>}}
kubectl create namespace airflow
{{< / highlight >}}

switch to the namespace

> kubectl config set-context &lt;context-name&gt; --namespace=airflow

e.g. 

{{< highlight shell>}}
kubectl config set-context dev1 --namespace=airflow
{{< / highlight >}}

### 2.2 clone the charts repository:

Since we are going to be using helm chart we will use values.yaml to make required changes.

{{< highlight shell>}}
git clone https://github.com/helm/charts.git
cd charts/stable/airflow
{{< / highlight >}}

We want to make following changes:

1. Get the code for our DAGS from our git repo. I have a sample repo at https://github.com/prabhatsharma/airflow-dags.
2. Setup postgres for airflow
3. Set up authentication using microsoft Active Directory.

Open values.yaml in a text editor and modify following sections:

### 2.3 Get the code for our DAGS from our git repo 

{{< highlight yaml "linenos=table,hl_lines=14,linenostart=312">}}
dags:
  ##
  ## mount path for persistent volume.
  ## Note that this location is referred to in airflow.cfg, so if you change it, you must update airflow.cfg accordingly.
  path: /usr/local/airflow/dags
  ##
  ## Set to True to prevent pickling DAGs from scheduler to workers
  doNotPickle: false
  ##
  ## Configure Git repository to fetch DAGs
  git:
    ##
    ## url to clone the git repository
    url:
    ##
    ## branch name, tag or sha1 to reset to
    ref: master

{{< / highlight >}}

to (see line 325)

{{< highlight yaml "linenos=table,hl_lines=14,linenostart=312,linenospecial=325">}}
dags:
  ##
  ## mount path for persistent volume.
  ## Note that this location is referred to in airflow.cfg, so if you change it, you must update airflow.cfg accordingly.
  path: /usr/local/airflow/dags
  ##
  ## Set to True to prevent pickling DAGs from scheduler to workers
  doNotPickle: false
  ##
  ## Configure Git repository to fetch DAGs
  git:
    ##
    ## url to clone the git repository
    url: https://github.com/prabhatsharma/airflow-dags
    ##
    ## branch name, tag or sha1 to reset to
    ref: master

{{< / highlight >}}

### 2.4 Set up postgres 

Airflow needs postgres to store state. You will want to setup a postgres if you have one already installed. If you don't have one already installed then you can let the chart install one for you.

{{< highlight yaml "linenos=table,linenostart=364">}}
postgresql:
  ##
  ## Use the PostgreSQL chart dependency.
  ## Set to false if bringing your own PostgreSQL.
  enabled: true
  ##
  ## If bringing your own PostgreSQL, the full uri to use
  ## e.g. postgres://airflow:changeme@my-postgres.com:5432/airflow?sslmode=disable
  # uri:
  ##
  ## PostgreSQL hostname
  ## postgresHost:
  ##
  ## PostgreSQL port
  service:
    port: 5432
  ## PostgreSQL User to create.
  postgresUser: postgres
  ##
  ## PostgreSQL Password for the new user.
  ## If not set, a random 10 characters password will be used.
  postgresPassword: airflow
  ##
  ## PostgreSQL Database to create.
  postgresDatabase: airflow
  ##
  ## Persistent Volume Storage configuration.
  ## ref: https://kubernetes.io/docs/user-guide/persistent-volumes
  persistence:
    ##
    ## Enable PostgreSQL persistence using Persistent Volume Claims.
    enabled: true
    ##
    ## Persistant class
    # storageClass: classname
    ##
    ## Access mode:
    accessMode: ReadWriteOnce
{{< / highlight >}}


### 2.5 Active directory authentication - Create image

We will need ldap3 module to be installed in the airflow image. However default image [puckel/docker-airflow](https://hub.docker.com/r/puckel/docker-airflow/) does not have airflow installed. so we will have to build our own image.

We will fork and clone this repo https://github.com/puckel/docker-airflow and add ldap3 module

{{< highlight shell>}}
git clone https://github.com/puckel/docker-airflow
cd docker-airflow
{{< / highlight >}}

Open Dockerfile in a text editor and add ldap3 module

{{< highlight yaml "linenos=table,hl_lines=3,linenostart=57">}}
&& pip install ndg-httpsclient \
&& pip install pyasn1 \
&& pip install ldap3 \
&& pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
&& pip install 'redis>=2.10.5,<3' \
{{< / highlight >}}

Now build the image

{{< highlight shell>}}
docker build . -t hiprabhat/airflow:latest 
docker push hiprabhat/airflow:latest
{{< / highlight >}}

Replace the name of your docker repo from hiprabhat/airflow

Now update the image section in values.yaml to:

{{< highlight yaml "linenos=table,hl_lines=4,linenostart=30">}}
  image:
    ##
    ## docker-airflow image
    repository: hiprabhat/airflow
    ##
    ## image tag
    tag: latest
    ##
    ## Image pull policy
    ## values: Always or IfNotPresent
    pullPolicy: IfNotPresent
    ##
    ## image pull secret for private images
    pullSecret:
{{< / highlight >}}

### 2.6 Active directory authentication - set up configuration
I already have an AD installed that I would be using.

{{< highlight yaml "linenos=table,linenostart=78">}}
  config:
    AIRFLOW__CORE__LOGGING_LEVEL: DEBUG
    AIRFLOW__CORE__LOAD_EXAMPLES: False
    AIRFLOW__WEBSERVER__AUTHENTICATE : True
    AIRFLOW__WEBSERVER__AUTH_BACKEND : airflow.contrib.auth.backends.ldap_auth

    AIRFLOW__LDAP__URI: LDAP://192.168.47.68:389
    AIRFLOW__LDAP__USER_FILTER: objectClass=*
    AIRFLOW__LDAP__USER_NAME_ATTR: sAMAccountName
    AIRFLOW__LDAP__GROUP_MEMBER_ATTR: memberOf

    AIRFLOW__LDAP__SUPERUSER_FILTER: memberOf=CN=airflow-super-users,OU=Users,OU=CORP,DC=eks,DC=prabhatsharma,DC=com
    AIRFLOW__LDAP__DATA_PROFILER_FILTER: memberOf=CN=airflow-super-users,OU=Users,OU=CORP,DC=eks,DC=prabhatsharma,DC=com

    AIRFLOW__LDAP__BIND_USER: CN=prabhat,OU=Users,OU=CORP,DC=eks,DC=prabhatsharma,DC=com
    AIRFLOW__LDAP__BIND_PASSWORD: MystrongPassword876755646
    AIRFLOW__LDAP__BASEDN: dc=eks,dc=prabhatsharma,dc=com
    AIRFLOW__LDAP__SEARCH_SCOPE: SUBTREE
    AIRFLOW__LDAP__CACERT: ""
{{< / highlight >}}


### 2.7 Now lets begin installation

{{< highlight shell>}}
helm install stable/airflow -f values.yaml
{{< / highlight >}}

### 2.8 Access you airflow installation

Let's check the services created by our helm chart:

{{< highlight shell>}}
kubectl get service
{{< / highlight >}}

Output:
{{< highlight shell>}}
NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
airflow-flower         ClusterIP   10.100.132.31    <none>        5555/TCP   30s
airflow-postgresql     ClusterIP   10.100.111.183   <none>        5432/TCP   30s
airflow-redis-master   ClusterIP   10.100.89.235    <none>        6379/TCP   30s
airflow-web            ClusterIP   10.100.9.65      <none>        8080/TCP   30s
airflow-worker         ClusterIP   None             <none>        8793/TCP   30s
{{< / highlight >}}

Now let's use port-forward to access the service

{{< highlight shell>}}
kubectl port-forward service/airflow-web 8080:8080
{{< / highlight >}}

Now point your browser to http://localhost:8080

![AIRFLOW LOGIN PAGE](/images/blog/airflow-login-page-small.png)

You can setup an ingress in front of your airflow-web service to make it accessible over internet.

Congratulations You are up and running with airflow!!!

# Comments
<div id="commento"></div>
<script src="https://cdn.commento.io/js/commento.js"></script>