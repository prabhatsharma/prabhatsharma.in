---
title: "eksuser - Amazon EKS user management tool"
date: 2018-12-04T14:53:24-08:00
draft: false
image: images/blog/k8s+iam.png
tags: ["eks", "kubernetes", "aws", "authentication", "iam",  "eksuser"]
author: Prabhat Sharma
type: post
---

# Amazon EKS user management

You have setup the EKS cluster and are able to use it. 

Now you want your teammates to access to the cluster too, so that they can build and run the applications. User management for EKS is done via the aws-auth configmap in kube-system namespace. You can learn how to add users manually by modifying the aws-auth configmap using the [official documentation](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html) which shows how to  add users to EKS by editing the aws-auth configmap.

Today we will learn how to add users using a tool called eksuser to make it easier to avoid any manual editing mistakes. 

This is where eksuser utility comes in. Let's see how it works.  We will do the following steps to add users.

1. Install eksuser
2. Create a Role and RoleBinding the will provide the appropriate rights to the users in the group.
3. Add the IAM user to the cluster under the created group
4. Configure machine of user who was added to the cluster by creating a kube-config file

## 1. Install eksuser

Download the appropriate binary for your platform from [https://github.com/prabhatsharma/eksuser/releases](https://github.com/prabhatsharma/eksuser/releases) and place it in the PATH.


## 2. Create Role and RoleBinding

Le'ts create a Role and RoleBinding for a group "super-developer" . 

Save the below text as super-developer.yaml . 

{{< highlight yaml>}}

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: super-developer
  namespace: app1
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]

---

kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: super-developer
  namespace: app1
subjects:
- kind: Group
  name: super-developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: super-developer
  apiGroup: rbac.authorization.k8s.io

{{< / highlight >}}

To add the above to your EKS cluster you can run:

{{< highlight shell>}}
$ kubectl apply -f super-developer.yaml
{{< / highlight >}}

This will provide access to all resources in namespace "app1" to users of "super-developer" group.

## 3. Add the IAM user to the cluster under the created group

Before we proceed let's take a look at the existing aws-auth configmap.

{{< highlight shell>}}
$ kubectl -n kube-system get configmap aws-auth -o yaml --export
{{< / highlight >}}

{{< highlight yaml>}}

apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::111122223333:role/doc-test-worker-nodes-NodeInstanceRole-WDO5P42N3ETB
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"mapRoles":"- rolearn: arn:aws:iam::111122223333:role/doc-test-worker-nodes-NodeInstanceRole-WDO5P42N3ETB\n  username: system:node:{{EC2PrivateDNSName}}\n  groups:\n    - system:bootstrappers\n    - system:nodes\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"aws-auth","namespace":"kube-system"}}
  creationTimestamp: 2018-04-04T18:49:10Z
  name: aws-auth
  namespace: kube-system
  resourceVersion: "780"
  selfLink: /api/v1/namespaces/kube-system/configmaps/aws-auth
  uid: dcc31de5-3838-11e8-af26-02e00430057c

{{< / highlight >}}

To add an existing IAM user to EKS run:

{{< highlight shell>}}
$ eksuser add --user=prabhat --group=super-developer
{{< / highlight >}}



Let's examine the aws-configmap again


{{< highlight yaml>}}

apiVersion: v1
data:
  mapRoles: |
    - rolearn: arn:aws:iam::111122223333:role/doc-test-worker-nodes-NodeInstanceRole-WDO5P42N3ETB
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::111122223333:user/prabhat
      username: prabhat
      groups:
        - super-developer
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"mapRoles":"- rolearn: arn:aws:iam::111122223333:role/doc-test-worker-nodes-NodeInstanceRole-WDO5P42N3ETB\n  username: system:node:{{EC2PrivateDNSName}}\n  groups:\n    - system:bootstrappers\n    - system:nodes\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"aws-auth","namespace":"kube-system"}}
  creationTimestamp: 2018-04-04T18:49:10Z
  name: aws-auth
  namespace: kube-system
  resourceVersion: "780"
  selfLink: /api/v1/namespaces/kube-system/configmaps/aws-auth
  uid: dcc31de5-3838-11e8-af26-02e00430057c

{{< / highlight >}}

To add an user to multiple groups:

{{< highlight shell>}}
$ eksuser add --user=prabhat --group=super-admin,super-developer
{{< / highlight >}}

To update an existing IAM user:

{{< highlight shell>}}
$ eksuser update --user=prabhat --group=super-developer
{{< / highlight >}}

To delete an existing user:

{{< highlight shell>}}
$ eksuser delete --user=prabhat
{{< / highlight >}}

This will remove the user from aws-auth configmap but won't delete the IAM user itself from AWS IAM.

To provide the user with admin privileges:

{{< highlight shell>}}
$ eksuser add --user=prabhat --group=system:masters
{{< / highlight >}}

From [https://kubernetes.io/docs/reference/access-authn-authz/rbac/](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) - <i>Allows super-user access to perform any action on any resource. When used in a ClusterRoleBinding, it gives full control over every resource in the cluster and in all namespaces. When used in a RoleBinding, it gives full control over every resource in the rolebinding's namespace, including the namespace itself.</i>



## 4. Configure machine of user who was added to the cluster by creating a kube-config file

You will need to configure the machine of the user who will be accessing the cluster. 

Following are the prerequisites:

1. aws-cli is installed and configured
    - Follow the [docs](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) if you don't already have it.
2. kubectl is installed and is in PATH
    - Follow steps in the [documentation](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) to install kubectl
3. aws-iam-authenticator is installed and is in PATH
    - Download and place the [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases) file in your PATH from github(https://github.com/kubernetes-sigs/aws-iam-authenticator/releases)

Then run the following command:

{{< highlight shell>}}
$ aws eks update-kubeconfig --name cluster_name
{{< / highlight >}}

This will create the ~/.kube/config file.

Now the user is all set to use kubectl with the cluster.

# Comments

<div id="commento"></div>
<script src="https://cdn.commento.io/js/commento.js"></script>
