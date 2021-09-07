---
title: "Video Encoding using ffmpeg to reduce file size before uploading to youtube"
date: 2021-09-06T10:50:14-07:00
draft: false
tags: ["video", "encoding", "youtube", "ffmpeg"]
author: Prabhat Sharma
type: post
# image: images/blog/ebs.png
---


When uploading videos to youtube thay can get huge and uploads might take a while. FFMPEG can reduce size of the files pretty heavily. I had a screencast of 190 MB that ffmpeg converted to 17 MB, which saved me a ton of time during upload considering upload bandwidth that my ISP gives is far lower than download bandwidth.

Below is the simple no-nosense command that you can use.

> ffmpeg -i RawInput.mkv encoded-output.mp4

You can also have filters during encoding. To reduce white noise you could use following.


> ffmpeg -i RawInput.mkv -af "afftdn=nt=w, afftdn=nt=w" encoded-output.mp4

-af is for audio filters.

To use video filters -vf

There are many other filters available if you need them. check them [here](https://ffmpeg.org/ffmpeg-filters.html).

Hope this saves you some space and time.

