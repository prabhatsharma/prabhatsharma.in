---
title: "How to connect to Kubernetes cluster resources(services, pods) using OpenVPN for local development"
date: 2018-10-19T04:38:07-07:00
draft: false
tags: ["kubernetes", "helm", "openvpn", "local development", "development workflow", "developer productivity"]
author: Prabhat Sharma
type: post
image: images/blog/k8s+openvpn.png
---

I wanted to do development locally on my laptop and I had some services that were running in my kubernetes cluster. I was trying to figure out the easiest way to access those resources without exposing them via a loadbalancer or nodeport for the specific service. This is when I thought if I could vpn into the cluster then it would allow me to access cluster resources from my laptop.

<i>
Note: I will be using an EKS cluster on AWS. You could use the same steps on other cloud providers too.
</i>

Let's get on to the steps to get it up and running. Our goal would be following:

1. Access cluster resources locally from my laptop. e.g. I should be able to access a ClusterIP service nginx from my local laptop by doing:

{{< highlight shell>}}
$ curl nginx.default.svc.cluster.local
{{< / highlight >}}
To achieve the above goal we will do following:

1. set up openvpn in the cluster
1. setup an openvpn client on my laptop.
1. Connect to cluster using the openvpn client
1. Create an nginx deployment and a service
1. Access the nginx service using curl and browser

## Step 1 - set up openvpn in the cluster

To make our life easier we will use helm. (You can look at [this article](/blog/helm-tutorial-the-package-manager-for-kubernetes-part-1/) on how to install helm if you don't already have it installed). Let's search for a helm chart for openvpn:

### Installation steps for helm v3

Search for the chart

{{< highlight shell>}}
$ helm search hub openvpn
{{< / highlight >}}

Output:
{{< highlight shell>}}
URL                                          	CHART VERSION	APP VERSION	DESCRIPTION
https://hub.helm.sh/charts/stable/openvpn    	4.2.0        	1.1.0      	A Helm chart to install an openvpn server insid...
https://hub.helm.sh/charts/cloudposse/openvpn	0.1.1        	           	A Helm chart for OpenVPN
{{< / highlight >}}

You can get the documentation for helm chart at https://hub.helm.sh/charts/stable/openvpn/4.2.0

Now that we have the chart that we want to install, let's create a namespace for it and get the kubernetes contexts.

{{< highlight shell>}}
kubectl create namespace openvpn

kubectl config get-contexts
{{< / highlight >}}

Output:
{{< highlight shell>}}
CURRENT   NAME                                                  CLUSTER                                               AUTHINFO                                              NAMESPACE
          arn:aws:eks:us-west-2:123456789862:cluster/oregon14   arn:aws:eks:us-west-2:123456789862:cluster/oregon14   arn:aws:eks:us-west-2:123456789862:cluster/oregon14   default
*         prabhat@basic3.us-west-2.eksctl.io                    basic3.us-west-2.eksctl.io                            prabhat@basic3.us-west-2.eksctl.io                    default
          prabhat@f1.us-east-2.eksctl.io                        f1.us-east-2.eksctl.io                                prabhat@f1.us-east-2.eksctl.io
          prabhat@ireland14.eu-west-1.eksctl.io                 ireland14.eu-west-1.eksctl.io                         prabhat@ireland14.eu-west-1.eksctl.io
{{< / highlight >}}

Now let's change the current namespace to the one that we created for openvpn installation.

{{< highlight shell>}}
kubectl config set-context prabhat@basic3.us-west-2.eksctl.io --namespace=openvpn

kubectl config get-contexts
{{< / highlight >}}

Output:
{{< highlight shell>}}
CURRENT   NAME                                                  CLUSTER                                               AUTHINFO                                              NAMESPACE
          arn:aws:eks:us-west-2:123456789862:cluster/oregon14   arn:aws:eks:us-west-2:123456789862:cluster/oregon14   arn:aws:eks:us-west-2:123456789862:cluster/oregon14   default
*         prabhat@basic3.us-west-2.eksctl.io                    basic3.us-west-2.eksctl.io                            prabhat@basic3.us-west-2.eksctl.io                    openvpn
          prabhat@f1.us-east-2.eksctl.io                        f1.us-east-2.eksctl.io                                prabhat@f1.us-east-2.eksctl.io
          prabhat@ireland14.eu-west-1.eksctl.io                 ireland14.eu-west-1.eksctl.io                         prabhat@ireland14.eu-west-1.eksctl.io
{{< / highlight >}}

Finally let's install openvpn
{{< highlight shell>}}
helm install openvpn stable/openvpn --version 4.2.0
{{< / highlight >}}

### installlation verification

Now let's check if our service is up and running:

{{< highlight shell>}}
$ kubectl get svc -n openvpn
{{< / highlight >}}

output:

{{< highlight shell>}}
NAME      TYPE           CLUSTER-IP       EXTERNAL-IP                                                              PORT(S)         AGE
openvpn   LoadBalancer   10.100.166.191   a22678678768456464656816........-123452019.us-west-2.elb.amazonaws.com   443:31015/TCP   3m
{{< / highlight >}}

Now let's follow the steps provided by the helm chart:

Now let's create a file  with following contents using editor of your choice:

create-key.sh
{{< highlight shell>}}
#!/bin/bash

if [ $# -ne 3 ]
then
  echo "Usage: $0 <CLIENT_KEY_NAME> <NAMESPACE> <HELM_RELEASE>"
  exit
fi

KEY_NAME=$1
NAMESPACE=$2
HELM_RELEASE=$3
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l "app=openvpn,release=$HELM_RELEASE" -o jsonpath='{.items[0].metadata.name}')
SERVICE_NAME=$(kubectl get svc -n "$NAMESPACE" -l "app=openvpn,release=$HELM_RELEASE" -o jsonpath='{.items[0].metadata.name}')
SERVICE_IP=$(kubectl get svc -n "$NAMESPACE" "$SERVICE_NAME" -o go-template='{{range $k, $v := (index .status.loadBalancer.ingress 0)}}{{$v}}{{end}}')
kubectl -n "$NAMESPACE" exec -it "$POD_NAME" /etc/openvpn/setup/newClientCert.sh "$KEY_NAME" "$SERVICE_IP"
kubectl -n "$NAMESPACE" exec -it "$POD_NAME" cat "/etc/openvpn/certs/pki/$KEY_NAME.ovpn" > "$KEY_NAME.ovpn"
{{< / highlight >}}

Now mark the file as executable

{{< highlight shell>}}
chmod +x create-key.sh
{{< / highlight >}}

Now create a key
{{< highlight shell>}}
./create-key.sh kubeVPN openvpn openvpn
{{< / highlight >}}

This will give you a file kubeVPN.ovpn in your current folder.

## Step 2 - Install OpenVPN client on your laptop
Since I am on mac I will use [Tunnelblick](https://tunnelblick.net/). For windows get client at [OpenVPN client](https://openvpn.net/community-downloads/).

## Step 3 - Connect to the VPN using openvpn client
Use the generated kubeVPN.ovpn file to connect to VPN.

## Step 4 - Create an nginx deployment and a service
To test if we are able to connect to cluster services from our laptop let's create an nginx service.

{{< highlight shell>}}
$ kubectl create deployment nginx --image=nginx
$ kubectl expose deployment/nginx --port=80
{{< / highlight >}}

Let's take a look at the nginx service that we create by running:

{{< highlight shell>}}
$ kubectl get svc nginx
{{< / highlight >}}

output:

{{< highlight shell>}}
Name:              nginx
Namespace:         default
Labels:            app=nginx
Annotations:       <none>
Selector:          app=nginx
Type:              ClusterIP
IP:                10.100.123.94
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         192.168.239.235:80
Session Affinity:  None
Events:            <none>
{{< / highlight >}}

## Step 5 - Access the nginx service using curl and browser
Now let's try to connect to nginx service:

{{< highlight shell>}}
$ curl nginx.default.svc.cluster.local
{{< / highlight >}}

This will give you the output. You could also check this in browser:

![Service in browser](/images/blog/nginx-kube-svc-openvpn-small.png)

We have successfully accessed our kubernetes ClusterIP service from our laptop. 

You could access any service in your kubernetes cluster using this mechanism during your development from your laptop where your code needs to access those services.

