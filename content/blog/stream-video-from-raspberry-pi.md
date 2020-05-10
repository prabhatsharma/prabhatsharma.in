---
title: "Stream Video From Raspberry Pi using Kinesis Video Streams"
date: 2020-05-10T05:02:47-07:00
draft: false
# image: images/blog/car/car2.jpg
tags: ["raspberry pi", "diy", "video", "streaming", "aws" ]
author: Prabhat Sharma
type: post
---

Kinesis video streams is one of the easiest way to stream your videos to internet. We will try it today using a raspberry pi.

I am using the below hardware for streaming video.

## Hardware that I will use:

Raspberry pi - https://www.raspberrypi.org/products/raspberry-pi-4-model-b/

Camera module - https://www.amazon.com/gp/product/B07L82XBNM/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1


# Steps:

## 1. On raspberry pi

Enable camera by running below and selecting appropriate options

```shell
raspi-config
```

Install dependencies

```
sudo apt-get install byacc flex
sudo apt-get install cmake
git clone https://github.com/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp --recursive
```

Note: Do not miss --recursive flag. If you miss it it will result in compilation errors later due to missing submodules.


optional

```
git checkout 5080cba # checking out to this commit will ensure that the steps below will work (Can't guarantee submodules though).
```

```
cd amazon-kinesis-video-streams-producer-sdk-cpp/ && mkdir build && cd build
```

```
time cmake .. -DBUILD_GSTREAMER_PLUGIN=ON
```

It took 17 minutes to run on my raspberry pi 4b

```
time make
```

This took another 1 minute 33 seconds

This will produce some binaries in your build folder like:

1. kinesis_video_gstreamer_audio_video_sample_app
1. kinesis_video_gstreamer_sample_app
1. kinesis_video_gstreamer_sample_multistream_app

You can use the above ninaries to push video streams to a kinesis video stream on AWS.

Let's set the credentials in environment variables first

```
export AWS_ACCESS_KEY_ID=<Access Key ID> 
export AWS_SECRET_ACCESS_KEY=<Secret Access Key> 
```


Now let's stream

```
kinesis_video_gstreamer_sample_app <name of your kinesis video stream>
```

## 2. On your laptop

Get the stream viewer:

git clone https://github.com/aws-samples/amazon-kinesis-video-streams-media-viewer

open the index.html file in browser. 
Pass the 
1. AWS credentials
1. stream name

Click "Start Playback". You are done.

