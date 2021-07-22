---
title: "Argo Workflow Authentication using Cognito"
date: 2021-07-21T21:28:07-07:00
draft: false
image: images/blog/aws_logo.png
tags: ["argo", "workflow", "kubernetes"]
author: Prabhat Sharma
type: post
---

Argo workflow supports SSO using 3rd part identity providers.

Amazon cognito is a very popular authentication provider that is almost free for most use cases that you can use for authenticating argo workflow.

In order to setup conto authentication you will have to do the following:

1. Create a cognito user pool
1. Setup a kubernetes secret containg cognito details
1. Configure argo workflow controller configmap.

Here are the sample values for congito secret:

```
apiVersion: v1
kind: Secret
metadata:
  name: sso-cognito
  namespace: argo
type: Opaque
data:
  client-id: td4duyfvf6c5iccjgdhtrds54=
  client-secret: gfhgfghfjkjljblblffhgfhfhMHUx45rdfcctrew4eufyjs3

```

Remeber that cclient-id and client-secret to base64 encoded values in secret.

Sample values for workflow controller configmap is:

```
# This file describes the config settings available in the workflow controller configmap
apiVersion: v1
kind: ConfigMap
metadata:
  name: workflow-controller-configmap
data:
  # SSO Configuration for the Argo server.
  # You must also start argo server with `--auth-mode sso`.
  # https://argoproj.github.io/argo-workflows/argo-server-auth-mode/
  sso: |
    # issuer: https://cognito-idp.{region}.amazonaws.com/{user pool id}
    issuer: https://cognito-idp.us-west-2.amazonaws.com/us-west-2_abcderfg
    sessionExpiry: 240h
    clientId:
      name: sso-cognito
      key: client-id
    clientSecret:
      name: sso-cognito
      key: client-secret
    redirectUrl: https://argo.mywebsite.com/oauth2/callback
    scopes:
    #  - groups
     - email
     - profile
     - openid
    rbac:
      enabled: true
```

You will also need to setup redirectUrl https://argo.mywebsite.com/oauth2/callback in cognito user pool.

This will get you up and running.


