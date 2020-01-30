---
title: "Google Cloudrun first experience and cost comparison to fargate"
date: 2020-01-30T04:17:59-08:00
draft: false
tags: ["containers", "serverless", "kubernetes", "cloud", "google", "aws"]
author: Prabhat Sharma
type: post
image: images/blog/gcp-cloudrun.png
---

I have good expereince running containers on fargate in AWS. I heard good things about cloudrun from someone during a conversation. Thought would give it a try.

So here we go.

Headed on to google https://console.cloud.google.com/run

1. Tried to create a test service. I thought I will provide the nginx image form docker hub. Unfortunately it would accept images only from GCR.
1. Tried picking up an [nginx image from gcr marketplace] (https://console.cloud.google.com/marketplace/details/google/nginx1) which is marketplace.gcr.io/google/nginx1:latest. Deployed it. However it failed after 3 minutes.
1. Tried looking at [docs](https://cloud.google.com/run/docs/quickstarts/build-and-deploy) and realized that the application running on container should be listening on PORT environment variable. Reminded me of elastic beanstalk :-)

{{<highlight go>}}
port := os.Getenv("PORT")
if port == "" {
        port = "8080"
}
{{</highlight>}}

Went ahead and built an image as specified in [docs](https://cloud.google.com/run/docs/quickstarts/build-and-deploy) and pushed it to gcr. Retried to create the service. And this time in less than a minute the service was up and gave me an https URL https://helloworld-gnbx23qqwa-uc.a.run.app/

Looked good.

Next I wanted to look at the price and compare it to fargate on AWS (Similar service on AWS that allows you to run containers without worrying about instances).


From cloudrun [pricing page](https://cloud.google.com/run#pricing)
<pre>
compute cost = $0.00002400 per vCPU‐second
memory cost = $0.00000250 per GB‐Second
requests = $0.40 per million requests
</pre>

Since the prices were per second and I wanted to compare against fargte prices (Which are published hourly even though billed on a per second basis)

So here is the extrapolation for Google Cloud run

<pre>
compute cost = $0.0864 per vCPU‐hour
memory cost = $0.009 per hour
requests = $0.40 per million requests
</pre>

[fargate cost on AWS] (https://aws.amazon.com/fargate/pricing/) gives you

<pre>
per vCPU per hour	$0.04048
per GB per hour	$0.004445
</pre>

#### Oh! Oh! GCP cloud run appears to be more than 2x expensive for compute and memory. Cloud run does have a free tier that you can use which fargate does not have.

Additionally, Spot pricing is also available for fargate that can make it even more cheaper.

Spot pricing for fargate:
<pre>
per vCPU per hour	$0.01215509
per GB per hour	$0.00133472
</pre>

spot prices give you 65% savings compared to fargate in on-demand mode.

For connectivity you will have to setup the load balancer on AWS which can be set up using the wizard.

Generally prices should not be considered solely from the point of infrastructure cost and should viewed from the perspective of TCO (total cost of ownership) which is where serverless platforms shine and help you reduce a lot of operational overhead compared to running containers on VMs.

**Conclusion**: It is relatively painless to start with cloud run. It can be used for quick experimentation and can work well for small or large workloads, however for running something at large scale it can get expensive compared to fargate based on the published prices especially if you can leverage spot pricing for fargate.

**Disclaimer**: I work for AWS. I have tried to be objective in my article here but feel free to let me know if you sense a bias via comments.

