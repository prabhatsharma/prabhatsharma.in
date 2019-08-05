---
title: "Using encrypted EBS Volumes with Kubernetes on AWS"
date: 2019-08-04T06:51:55-07:00
draft: false
tags: ["k8s", "kubernetes", "eks", "aws", "amazon"]
author: Prabhat Sharma
type: post
image: images/blog/ebs.png
---

Lot of people run Kubernetes on AWS and need to use encrypted EBS volumes for security and compliace. 

I will lay down the steps below in order to use it.

<!-- 1. Assign proper permissions to worker nodes -->
1. Create a storage class
1. Create a PersistentVolume (or dynamically provisoned PersistentVolumeClaim) using the storage class
1. Create a pod to use the PersistentVolumeClaim

<!-- ## 1. Assign proper permissions to worker nodes

Your worker nodes must have the following policy attached to their associated IAM role in order for them to use encrypted volume.

{{< highlight json "linenos=table">}}
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:CreateGrant"
            ],
            "Resource": "*"
        }
    ]
}
{{< / highlight >}} -->


## 1. Create a storage class

You must create a storage class that can be used for creating a PV/PVC.

Create a file <i style="font-weight:bold;">encrypted-gp2.yaml</i> with below contents.

{{< highlight yaml "linenos=table">}}
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: encrypted-gp2
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  fsType: ext4
  encrypted: "true"
{{< / highlight >}}

<br>
Create the StorageClass by running below command
{{< highlight shell "linenos=table">}}
kubectl -f encrypted-gp2.yaml
{{< / highlight >}}

## 2. Create a PersistentVolume or a dynamically provisioned PersistentVolumeClaim

Let's create a dynamically provisioned PersistentVolumeClaim.

Create a file <i style="font-weight:bold;">encrypted-pvc.yaml</i> with below contents.

{{< highlight yaml "linenos=table">}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app1-pvc
spec:
  storageClassName: encrypted-gp2
  accessModes:
    - ReadWriteOnce
  volumeMode: Block
  resources:
    requests:
      storage: 10Gi
{{< / highlight >}}

<br>
Create the PersistentVolumeClaim by running below command
{{< highlight shell "linenos=table">}}
kubectl -f encrypted-pvc.yaml
{{< / highlight >}}

## 3. Create a pod to use the PVC


{{< highlight yaml "linenos=table">}}
apiVersion: v1
kind: Pod
metadata:
  name: app1
spec:
  containers:
    - name: app1
      image: nginx
      volumeMounts:
      - mountPath: "/var/www/html"
        name: mypd
  volumes:
    - name: mypd
      persistentVolumeClaim:
        claimName: app1-pvc
{{< / highlight >}}

That is all you need to use encrypted EBS volumes with Kubernetes on AWS. 


