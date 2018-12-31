---
title: "Helm tutorial - The package manager for kubernetes - Part 1"
date: 2018-10-13T19:36:35-07:00
tags: ["kubernetes", "helm", "package manager"]
author: Prabhat Sharma
type: post
image: images/blog/helm-logo.png
draft: false
---

I have been asked by various people on what is the best way to install and manage applications on kubernetes. In fact a lot of people want to install various readily available solutions like mysql, mariadb, mongodb, nginx etc. For stateless applications its generally straightforward and nobody is bothered much, however when it comes to stateful applications one starts to think how they will manage to install it. 

Does one have to go through the rigmarole of installing the application just like installing it on instances?

Let's take an example of mongodb. To install mongodb on kubernetes you would do following:

1. Create a stateful set 
1. Create a  service
1. Set up replication among the pods created by stateful set

Doing this by yourself can be good amount of work. You may also try to do some search around ready made scripts that you could use. However let's make our life easier by using helm to install mongodb.

Assuming you have helm installed, setting up a replicated mongodb cluster in kubernetes will take just 1 line command:

<span>{{< highlight shell>}}
$ helm install stable/mongodb-replicaset
{{< / highlight >}}</span>

After you run the above command, it will take a couple of minutes and your mongodb cluster is ready. Wow!!! that was super easy.

Before we get further let's understand the architecture of helm.

Helm consists of 

1. helm client - A client binary that runs on the same machine (Your laptop/desktop) as kubectl.
1. tiller - A server component that accepts commands from helm client and executes them on the kubernetes cluster. This is essentially a pod.
1. Chart(s) - Think of it as a collection of yaml files of (deployment, service, configmap, etc...) for now. These can be customized as required during installation.
1. Chart repository - This is an optional component. It's a server that would store the charts. helm client can search and fetch these charts for installation/upgrade on a kubernetes cluster. 

You install applications using something called charts. A chart can be thought of as a collection of deployment(s), service(s), configmap(s), statefulset(s), etc that will be executed by tiller to install the specific application.

Charts can be stored in a remote repository or they can be locally on your laptop.

![Helm Architecture](/images/blog/helm-architecture.png)

Now let's get to the steps to make everything up and running.

1. Install helm by downloading the release from [https://github.com/helm/helm/releases](https://github.com/helm/helm/releases) for your platform and put it in path. For e.g. for mac
{{< highlight shell>}}
$ wget -c https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-darwin-amd64.tar.gz -O - | tar -xz 
$ sudo mv ./darwin-amd64/helm /usr/local/bin/
{{< / highlight >}}
1. Install tiller by running: 
{{< highlight shell>}}
$ helm init
{{< / highlight >}}
1. Now run following commands to give permissions to tiller for performing operations
{{< highlight shell>}}
$ kubectl -n kube-system create serviceaccount tiller
$ kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
$ kubectl -n kube-system patch deploy tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
{{< / highlight >}}



Using above commands you are giving cluster-admin rights to tiller so that it can perform any and all tasks in the cluster. This works well in a development environment, however you would want to limit access rights of tiller to only what is required to maintain security and conform to least privilege principle in production and untrusted environments.

Once you have helm and tiller installed you are good to go.

To search for a particular chart in the default repo - eg. mysql, you would run:

{{< highlight shell>}}
$ helm search mysql
{{< / highlight >}}

OUTPUT:

{{< highlight shell>}}
NAME                            	CHART VERSION	APP VERSION	DESCRIPTION
incubator/mysqlha               	0.4.0        	5.7.13     	MySQL cluster with a single master and zero or more slave...
stable/mysql                    	0.10.1       	5.7.14     	Fast, reliable, scalable, and easy to use open-source rel...
stable/mysqldump                	1.0.0        	5.7.21     	A Helm chart to help backup MySQL databases using mysqldump
stable/prometheus-mysql-exporter	0.1.0        	v0.10.0    	A Helm chart for prometheus mysql exporter with cloudsqlp...
stable/percona                  	0.3.2        	5.7.17     	free, fully compatible, enhanced, open source drop-in rep...
stable/percona-xtradb-cluster   	0.2.0        	5.7.19     	free, fully compatible, enhanced, open source drop-in rep...
stable/phpmyadmin               	1.1.2        	4.8.2      	phpMyAdmin is an mysql administration frontend
stable/gcloud-sqlproxy          	0.5.0        	1.11       	Google Cloud SQL Proxy
stable/mariadb                  	5.0.9        	10.1.36    	Fast, reliable, scalable, and easy to use open-source rel...
{{< / highlight >}}

To do our experiments let's create a new namespace:

{{< highlight shell>}}
$ kubectl create namespace hex
{{< / highlight >}}

To install mysql you could run:

{{< highlight shell>}}
$ helm install stable/mysql --name=mysql-dev --namespace=hex
{{< / highlight >}}

This will give following output:

{{< highlight shell>}}
NAME:   mysql-dev
LAST DEPLOYED: Sat Oct 13 22:06:38 2018
NAMESPACE: hex
STATUS: DEPLOYED

RESOURCES:
==> v1/PersistentVolumeClaim
NAME       AGE
mysql-dev  0s

==> v1/Service
mysql-dev  0s

==> v1beta1/Deployment
mysql-dev  0s

==> v1/Pod(related)

NAME                        READY  STATUS   RESTARTS  AGE
mysql-dev-7fd5d8c558-p6vs2  0/1    Pending  0         0s

==> v1/Secret

NAME       AGE
mysql-dev  0s

==> v1/ConfigMap
mysql-dev-test  0s


NOTES:
MySQL can be accessed via port 3306 on the following DNS name from within your cluster:
mysql-dev.hex.svc.cluster.local

To get your root password run:
    MYSQL_ROOT_PASSWORD=$(kubectl get secret --namespace hex mysql-dev -o jsonpath="{.data.mysql-root-password}" | base64 --decode; echo)

To connect to your database:
1. Run an Ubuntu pod that you can use as a client:
    kubectl run -i --tty ubuntu --image=ubuntu:16.04 --restart=Never -- bash -il
2. Install the mysql client:
    $ apt-get update && apt-get install mysql-client -y
3. Connect using the mysql cli, then provide your password:
    $ mysql -h mysql-dev -p

To connect to your database directly from outside the K8s cluster:
    MYSQL_HOST=127.0.0.1
    MYSQL_PORT=3306

    # Execute the following command to route the connection:
    kubectl port-forward svc/mysql-dev 3306

    mysql -h ${MYSQL_HOST} -P${MYSQL_PORT} -u root -p${MYSQL_ROOT_PASSWORD}
{{< / highlight >}}

Congratulations!!! Now you have a running mysql database.

Every time you install a chart helm creates a release. A release can be upgraded or deleted. To list existing releases run:

{{< highlight shell>}}
$ helm ls
{{< / highlight >}}

This would give the following output:

{{< highlight shell>}}
NAME       	REVISION	UPDATED                 	STATUS  	CHART                   	APP VERSION	NAMESPACE
mysql-dev  	1       	Sat Oct 13 22:06:38 2018	DEPLOYED	mysql-0.10.1            	5.7.14     	hex
{{< / highlight >}}

To delete the release you can run:

{{< highlight shell>}}
$ helm delete mysql-dev 
{{< / highlight >}}

Try again

{{< highlight shell>}}
$ helm ls
{{< / highlight >}}

You should get no output:

{{< highlight shell>}}
NAME       	REVISION	UPDATED                 	STATUS  	CHART                   	APP VERSION	NAMESPACE
{{< / highlight >}}

In fact helm does not totally delete the release. To see the deleted releases you can try:

{{< highlight shell>}}
$ helm ls --all
{{< / highlight >}}

You should get output:

{{< highlight shell>}}
NAME              	REVISION	UPDATED                 	STATUS  	CHART                   	APP VERSION	NAMESPACE
mysql-dev         	1       	Sat Oct 13 22:06:38 2018	DELETED 	mysql-0.10.1            	5.7.14     	hex
{{< / highlight >}}

To delete the release fully you can run:

{{< highlight shell>}}
$ helm delete mysql-dev --purge
{{< / highlight >}}

To see various helm commands just run:

{{< highlight shell>}}
$ helm
{{< / highlight >}}
This will show you all available commands that you can use. To learn more about a particular command you can type --help. e.g.

{{< highlight shell>}}
$ helm list --help
{{< / highlight >}}

Thats all for this post. 

# Comments
<div id="commento"></div>
<script src="https://cdn.commento.io/js/commento.js"></script>