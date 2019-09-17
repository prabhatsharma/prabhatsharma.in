---
title: "Infrastructure as Template vs Code"
date: 2019-08-15T15:57:59-07:00
draft: true
image: images/blog/airflow-logo.jpeg
tags: ["aws", "IaaC", "cloudformation", "terraform", "pulumi", "cdk", "automation", "cloud"]
author: Prabhat Sharma
type: post
---

Infrastructure as code really started with cloudformation in [May 15th 2010](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/ReleaseHistory.html)

Terraform started in [2015](https://github.com/hashicorp/terraform/graphs/code-frequency) and it has been very popular amongst cloud customers.

Both of the above tools started the revolution around IaaC and allowed engineers to build infrastructure using code and automate it. They could put the templates in a version control and track the changes made. They were huge improvement from the earlier era when everything had to be done manually. Teams loved it.

A lot of solutions were built using these tools that engineers can simply run and get their entire infrastructure up and running.

These tools use a specific DSL (Domain specific language) and are more like templates written in JSON/YAML (Cloudformation) or HCL (Hashicorp Configuration Language). You have to provide the resources and confirguration for them upfront. While they do provide some specific functions for providing dynamism and later steps can use the output produced by earlier steps they really lacked the aability to program the infrastructure in the true sense. 





