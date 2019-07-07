---
title: "Amazon EKS IAM authentication: How to add an IAM user"
date: 2018-10-26T08:26:08-07:00
image: images/blog/eks.svg
draft: false
tags: ["eks", "kubernetes", "aws", "authentication", "iam"]
author: Prabhat Sharma
type: post
---
<b><i>Note: This blog provides a deep dive on EKS authentication. If your goal is to be able to just add/delete eks users then follow this [eksuser-amazon-eks-user-management-tool](../eksuser-amazon-eks-user-management-tool)</i></b>

When you create an EKS cluster it uses credentials of the user creating the cluster to set things up and assigns the user cluster-admin rights on the cluster through kubernetes RBAC.

EKS uses IAM for authentication. It uses [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator) for authentication using [webhook token authentication](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#webhook-token-authentication) of kubernetes. For authorization EKS uses kubernetes RBAC.

The flow looks like:

![EKS Auth Flow](/images/blog/eks-auth.png)

In this post we will learn how to add an IAM user to EKS for him/her to access kubernetes resources. 

Let's say there are 3 people:

![EKS Users](/images/blog/eks-users.png)

1. Prabhat - created the cluster. Hence has admin privileges on the cluster.
1. Adam - the cluster admin that prabhat will add to EKS
1. Dave - the developer that prabhat will add to EKS

The steps that we will follow are:

## 1. On Prabhat's laptop in AWS account:

1. Create an IAM policy that will be used the IAM users. (skip if you already have a policy with required rights. check details for additional info)
1. Create an IAM user for Adam and Dave (skip if you already have the users) 
1. Attach policy to the IAM user (skip if existing setup already has rights)
1. Generate aws <b>AccessKeyId</b> and <b>SecretAccessKey</b> for Adam and Dave

## 2. From Prabhat's laptop on EKS cluster:

1. Add the IAM users adam and dave to the cluster configmap aws-auth
1. Create an admin EKS ClusterRole and a developer ClusterRole
1. Create an EKS ClusterRoleBinding for both ClusterRoles

## 3. On the machine of the Adam and Dave IAM users who will access the EKS cluster:

1. Set up AWS CLI  by following the steps [here](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
1. Install kubectl
1. Install aws-iam-authenticator
1. Generate the kubeconfig file
1. Access the cluster

Now let's get into details.

## 1. On Prabhat's laptop in AWS account:

- 1. Create an IAM policy that will be used by the IAM users.

You don't really need to create a new policy, but we will create a minimal policy that is required. Essentially we need the user to have 2 rights. eks:ListCluster, eks:DescribeCluster . These will be used to generate the kubeconfig for connecting to the cluster by Adam and Dave.

Now let's create the policy.
{{< highlight shell>}}
$ aws iam create-policy --policy-name=eks-readonly --policy-document='{"Version": "2012-10-17", "Statement": {"Sid": "45345354354", "Effect": "Allow", "Action": ["eks:DescribeCluster", "eks:ListCluster" ], "Resource": "*" }}'
{{< / highlight >}}
Output: 

{{< highlight json>}}
    {
    "Policy": {
        "PolicyName": "eks-readonly",
        "PolicyId": "ANPAID2WKUBOUCNJMOOL2",
        "Arn": "arn:aws:iam::012345678910:policy/eks-readonly",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "IsAttachable": true,
        "CreateDate": "2018-10-28T00:25:20Z",
        "UpdateDate": "2018-10-28T00:25:20Z"
        }
    }
{{< / highlight >}}


- 2. Create an IAM user for Adam and Dave

{{< highlight shell>}}
$ aws iam create-user --user-name=adam
$ aws iam create-user --user-name=dave
{{< / highlight >}}

- 3. Attach the IAM policy to both users

{{< highlight shell>}}
$ aws iam attach-user-policy --user-name=adam --policy-arn=arn:aws:iam::012345678910:policy/eks-readonly
$ aws iam attach-user-policy --user-name=dave --policy-arn=arn:aws:iam::012345678910:policy/eks-readonly
{{< / highlight >}}

- 4. Generate aws <b>AccessKeyId</b> and <b>SecretAccessKey</b> for Adam and Dave

{{< highlight shell>}}
$ aws iam create-access-key --user-name=adam
$ aws iam create-access-key --user-name=dave
{{< / highlight >}}

Capture and keep the <b>AccessKeyId</b> and <b>SecretAccessKey</b> obtained in this step. You will need it when configuring machines oof Adam and Dave during AWS CLI configuration.

## 2. From Prabhat's laptop on EKS cluster:

- 1. Add the IAM users adam and dave to the cluster configmap aws-auth

First get the dump of existing aws auth configmap

{{< highlight shell>}}
$ kubectl -n kube-system get configmap aws-auth -o yaml > aws-auth.yaml
{{< / highlight >}}

This would create a file with below contents:

{{< highlight yaml>}}
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::012345678910:role/EKS-dev3-DefaultNodeGroup-NodeInstanceRole-1Q9T2ZHVLGCU1
      username: system:node:{{EC2PrivateDNSName}}
kind: ConfigMap
metadata:
  creationTimestamp: 2018-09-01T15:32:05Z
  name: aws-auth
  namespace: kube-system
{{< /highlight>}}

Modify aws-auth.yaml to add dave and adam to mapUsers section:

{{< highlight yaml>}}
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::012345678910:role/EKS-dev3-DefaultNodeGroup-NodeInstanceRole-1Q9T2ZHVLGCU1
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
    - userarn: arn:aws:iam::012345678910:user/dave
      username: dave
    - userarn: arn:aws:iam::012345678910:user/adam
      username: adam
kind: ConfigMap
metadata:
  creationTimestamp: 2018-09-01T15:32:05Z
  name: aws-auth
  namespace: kube-system
{{< /highlight>}}

{{< highlight shell>}}
$ kubectl -n kube-system apply -f aws-auth.yaml'
{{< / highlight >}}

- 2. Create an admin EKS ClusterRole and a developer ClusterRole

admin will have rights over all the resources.

create a file adminClusterRole.yaml
{{< highlight yaml>}}
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: myadmin
rules:
- apiGroups: [ "*" ]
  resources: ["*"]
  verbs: ["*"]
- nonResourceURLs: ["*"]
  verbs: ["*"]
{{< / highlight >}}

Run:
{{< highlight shell>}}
$ kubectl apply -f adminClusterRole.yaml
{{< / highlight >}}

Developer will have rights only to the namespace "app1". Since the rights of developer are only for a particular namespace we will create a Role instead of a ClusterRole.

create a file developerRole.yaml
{{< highlight yaml>}}
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: mydeveloper
  namespace: app1
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
{{< / highlight >}}

Run:
{{< highlight shell>}}
$ kubectl apply -f developerRole.yaml
{{< / highlight >}}

- 3. Create an EKS ClusterRoleBinding and RoleBinding

adminClusterRoleBinding.yaml
{{< highlight yaml>}}
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: myadmin
subjects:
- kind: User
  name: adam
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: myadmin
  apiGroup: rbac.authorization.k8s.io
{{< / highlight >}}

Run:
{{< highlight shell>}}
$ kubectl apply -f adminClusterRoleBinding.yaml
{{< / highlight >}}

Since developer access is restricted to a namespace app1 we will create a RoleBinding (as opposed to ClusterRoleBinding)
developerRoleBinding.yaml
{{< highlight yaml>}}
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: mydeveloper
  namespace: app1
subjects:
- kind: User
  name: dave
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: mydeveloper
  apiGroup: rbac.authorization.k8s.io
{{< / highlight >}}

Run:
{{< highlight shell>}}
$ kubectl apply -f developerRoleBinding.yaml
{{< / highlight >}}

## 3. On the machine of the Adam and Dave IAM users who will access the EKS cluster:

- 1. Set up AWS CLI  by following the steps [here](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- 2. Install kubectl using instruction [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl)
- 3. Install aws-iam-authenticator using steps from [EKS docs](https://docs.aws.amazon.com/eks/latest/userguide/configure-kubectl.html)
- 4. Generate the kubeconfig file
{{< highlight shell>}}
$ aws eks update-kubeconfig --name=<cluster-name>
{{< / highlight >}}

Follow the steps on machines of both Adam and Dave

We are all done here. Now let's access the cluster

#### On Dave's machine

Try following:

{{< highlight shell>}}
$ kubectl get pods
{{< / highlight >}}

Output:

{{< highlight shell>}}
Error from server (Forbidden): pods is forbidden: User "dave" cannot list pods in the namespace "default"
{{< / highlight >}}

Since Dave does not have access to default namespace the above command fails. Let's check if the commands in namespace app1 succeeds.

{{< highlight shell>}}
$ kubectl get pods -n app1
{{< / highlight >}}

Output:

{{< highlight shell>}}
NAME                       READY   STATUS    RESTARTS   AGE
mongodb-84b7c86ff5-jqz97   1/1     Running   0          6d
mysql-58d5cb6fd4-rznkd     1/1     Running   0          5d
{{< / highlight >}}

Voila! This succeeds as expected. Congratulations Dave.

#### On Adam's machine

{{< highlight shell>}}
$ kubectl get ns
{{< / highlight >}}

Output:

{{< highlight shell>}}
NAME             STATUS   AGE
app1             Active   12d
default          Active   14d
grafana          Active   5d
istio-system     Active   13d
jaeger           Active   13d
kube-public      Active   14d
kube-system      Active   14d
metrics          Active   6d
openvpn          Active   12d
prometheus       Active   6d
spinnaker        Active   6d
test1            Active   14d
{{< / highlight >}}


Congratulations. This works for Adam. 

Adam can run many more commands in any namespace with success.

# Bonus

Now the above steps are a bit too much just to add/delete users. I built an utility tool to make it easy to manage EKS users. It's called eksuser. Head over to [eksuser-amazon-eks-user-management-tool](../eksuser-amazon-eks-user-management-tool) to find out, how it works.


# Comments
<div id="commento"></div>
<script src="https://cdn.commento.io/js/commento.js"></script>

