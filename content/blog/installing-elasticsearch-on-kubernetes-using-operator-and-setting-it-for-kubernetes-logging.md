---
title: "Installing Elasticsearch on Kubernetes Using Operator and setting it for Kubernetes logging"
date: 2019-08-07T14:09:20-07:00
draft: false
tags: ["kubernetes", "logging", "elasticsearch", "fluentd", "fluent-bit", "kibana", "helm"]
author: Prabhat Sharma
type: post
image: images/blog/k8s-logging.png
---

In an [earlier blog post](../logging-in-kubernetes-using-elasticsearch-the-easy-way) I provided the steps to install elastisearch using helm and setting it up for logging using fluent-bit. With the introduction of elasticsearch operator the experience of managing the elasticsearch cluster in kubernetes has improved greatly. We will cover the same goal of setting up elastisearch and configuring it for logging as the earlier blog, with the same ease but much better experience.

Using operator allows you benefits in the area of security, upgrades and scalability. To learn more read the [ealstic blog](https://www.elastic.co/blog/introducing-elastic-cloud-on-kubernetes-the-elasticsearch-operator-and-beyond)

Let's look at the steps that we will be following:

1. Install the Elasticsearch operator
2. Install Elasticsearch using operator
3. Install Kibana using operator
4. Install fluent-bit

# Step 1 - Install the Elasticsearch operator

Just run the below command. It will install teh CRDs and the controller that will help in managing the clusters.

{{< highlight shell>}}
kubectl apply -f https://download.elastic.co/downloads/eck/0.9.0/all-in-one.yaml
{{< / highlight>}}

# Step 2 - Install Elasticsearch using operator

Create a namespace logs using the below command:

{{< highlight shell>}}
kubectl create ns logs
{{< / highlight>}}

Next prepare the below <b><i>elasticsearch.yaml</i></b> definition file.

{{< highlight yaml "linenos=table">}}
apiVersion: elasticsearch.k8s.elastic.co/v1alpha1
kind: Elasticsearch
metadata:
  name: es-logs
  namespace: logs
spec:
  version: 7.2.0
  nodes:
  - nodeCount: 3
    config:
      node.master: true
      node.data: true
      node.ingest: true
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 50Gi

{{< / highlight >}}


You can also install the above using the single below line.

{{< highlight shell>}}
kubectl apply -f https://raw.githubusercontent.com/prabhatsharma/elasticsearch-using-operator/master/elasticsearch.yaml
-
{{< / highlight>}}

Test the installation using the below command:

{{< highlight shell>}}
kubectl -n logs get pods
{{< / highlight>}}

Output:

{{< highlight text "linenos=table">}}
NAME                              READY   STATUS    RESTARTS   AGE
es-logs-es-257qmwwhr9             1/1     Running   0          3m
es-logs-es-84v87tkwpp             1/1     Running   0          3m
es-logs-es-rmzbxh9mr4             1/1     Running   0          3m
{{< / highlight >}}

Get the password for elasticsearch using the below command. You will need this later to setup fluent-bit and login to your cluster.

{{< highlight shell>}}
kubectl -n logs get secret es-logs-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode
{{< / highlight>}}

# Step 3 - Install Kibana using operator

Create a below <b><i>kibana.yaml</i></b> definition file.

{{< highlight yaml "linenos=table">}}
apiVersion: kibana.k8s.elastic.co/v1alpha1
kind: Kibana
metadata:
  name: kibana-logs
  namespace: logs
spec:
  version: 7.2.0
  nodeCount: 1
  elasticsearchRef:
    name: es-logs

{{< / highlight >}}

You can also apply it using the below 1 line command. 

{{< highlight shell>}}
kubectl apply -f https://raw.githubusercontent.com/prabhatsharma/elasticsearch-using-operator/master/kibana.yaml
_
{{< / highlight>}}

Test the installation using the below command:

{{< highlight shell>}}
kubectl -n logs get pods
{{< / highlight>}}

Output:

{{< highlight text "linenos=table">}}
NAME                              READY   STATUS    RESTARTS   AGE
es-logs-es-257qmwwhr9             1/1     Running   0          5m
es-logs-es-84v87tkwpp             1/1     Running   0          5m
es-logs-es-rmzbxh9mr4             1/1     Running   0          5m
kibana-logs-kb-68c5c9596b-xn4lh   1/1     Running   0          1m
{{< / highlight >}}

To log on to kibana using port forwarding use below command:

{{< highlight shell>}}
kubectl -n logs port-forward svc/kibana-logs-kb-http 5601:5601
{{< / highlight>}}

Now go to https://localhost:5601  and login using below credentials<br>
User ID: elastic <br>
Password: Output of command ($ kubectl get secret quickstart-es-elastic-user -o=jsonpath='{.data.elastic}' | base64 --decode)

<img src="/images/blog/kibana-using-operator.png" width="800px">

# Step 4 - Install fluent-bit

We will use helm to install fluent-bit

Download the fluent-bit helm values file using below command:

{{< highlight shell>}}
wget https://raw.githubusercontent.com/prabhatsharma/elasticsearch-using-operator/master/fluent-bit-values.yml
_
{{< / highlight>}}

{{< highlight yaml "linenos=table">}}

backend:
  type: es
  es:
    host: es-logs-es-http
    port: 9200
    # Optional username credential for Elastic X-Pack access
    http_user: elastic
    # Password for user defined in HTTP_User
    http_passwd: kjhffgsdwhgvbk289txz8
    # Optional TLS encryption to ElasticSearch instance
    tls: "on"
    tls_verify: "off"

{{< / highlight >}}

Set the http_passwd value to what you got in step 2

Now install fluentbit and configure it using below command

{{< highlight shell>}}
helm install stable/fluent-bit --name=fluent-bit --namespace=logs -f fluent-bit-values.yml
{{< / highlight >}}

Test the installation using the below command:

{{< highlight shell>}}
kubectl -n logs get pods
{{< / highlight>}}
Output:

{{< highlight text "linenos=table">}}
NAME                              READY   STATUS    RESTARTS   AGE
es-logs-es-257qmwwhr9             1/1     Running   0          8m
es-logs-es-84v87tkwpp             1/1     Running   0          8m
es-logs-es-rmzbxh9mr4             1/1     Running   0          8m
fluent-bit-7zwzs                  1/1     Running   0          1m
fluent-bit-mblh9                  1/1     Running   0          1m
kibana-logs-kb-68c5c9596b-xn4lh   1/1     Running   0          3m
{{< / highlight >}}


After this step you should be able to access logs using kibana.

<br>
References

- https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-quickstart.html
- https://www.elastic.co/blog/introducing-elastic-cloud-on-kubernetes-the-elasticsearch-operator-and-beyond
