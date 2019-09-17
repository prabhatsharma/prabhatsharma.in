---
title: "Getting Started With Blogging Using Ghost on Kubernetes"
date: 2019-08-10T18:40:13-07:00
draft: true
tags: ["k8s", "kubernetes", "monitoring", "Prometheus", "Istio"]
author: Prabhat Sharma
type: post
---


helm install stable/mariadb --name=mariadb --namespace=mariadb

Get mariadb root credentials

echo $(kubectl get secret --namespace mariadb mariadb -o jsonpath="{.data.mariadb-root-password}" | base64 --decode)

wget https://raw.githubusercontent.com/helm/charts/master/stable/ghost/values.yaml -O ghost-values.yaml

modify ghost values.yaml

externalDatabase:
  host: mariadb.mariadb.svc.cluster.local
  port: 3306
  user: root
  password: z2b76daaBm
  database: ghost
mariadb:
  enabled: false

service:
  type: ClusterIP

ghostProtocol: http
ghostHost: ghost.prabhatsharma.com

helm install stable/ghost --name=ghost --namespace=ghost -f ghost-values.yaml

create ingress

k apply -f static/yaml/ghost-ingress.yaml 


echo Email:    hi.prabhat@gmail.com
echo Password: $(kubectl get secret --namespace ghost ghost -o jsonpath="{.data.ghost-password}" | base64 --decode)


