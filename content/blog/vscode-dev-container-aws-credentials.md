---
title: "VScode Dev Container AWS Credentials"
date: 2021-01-30T06:31:00-08:00
draft: true
image: images/blog/aws_logo.png
draft: false
tags: ["aws", "vscode", "development", "containers", "docker"]
author: Prabhat Sharma
type: post
---

Lately I have been using VS code dev containers quite a lot. I also use AWS pretty extensively. So when I started using dev containers and found that calls to AWS services are failing from my dev container, I looked for a solution.

Here is how I solved it.


On you local machine when you try to call aws services e.g. aws s3 ls - It fetches your credentials from ~/.aws/credentials file. This is the file where your aws access and secret access tokens are stored that are fetched by AWS CLI and SDK. The solution to get AWS SDK and CLI to work in your container would be to have the credentials file available in the container. One idea would be to use the Dockerfile COPY. DO NOT do this since it may leak your credentials if you somehow publish the container to docker hub public repo. 

The right way to do it would be to mount the directory directly in dev container. When you are using dev containers you have a file - .devcontainer/devcontainer.json in the root of your source code. You can add configuration to this file for mounting your credentials to the dev container.

Just add the mounts section in the config file and your calls to aws services will start working. See below for example.

{{< highlight json>}}
{
	"name": "Python 3",
	"build": {
		"dockerfile": "Dockerfile",
		"context": "..",
		"args": { 
			// Update 'VARIANT' to pick a Python version: 3, 3.6, 3.7, 3.8, 3.9
			"VARIANT": "3.8",
			// Options
			"INSTALL_NODE": "true",
			"NODE_VERSION": "lts/*"
		},
	},
	"mounts": [
		"source=/Users/prabhsha/.aws/credentials,target=/home/vscode/.aws/credentials,type=bind,consistency=cached"
	]
}
{{< / highlight >}}


