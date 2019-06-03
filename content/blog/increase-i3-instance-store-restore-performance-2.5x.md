---
title: "Increase i3 instance store restore performance by 2.5x"
date: 2019-06-03T10:12:31-08:00
draft: false
image: images/blog/ebs+i3.png
tags: ["ebs", "ec2", "instance store", "aws", "performance",  "IO", "st1"]
author: Prabhat Sharma
type: post
---


EC2 i3 instances are great for scenarios where you require very high read/write performance as it provides you with locally attached instance store volumes upto 2 million read IOPS and 1.6 million write IOPS (for i3en.24xlarge). You can find details on available performance on these volumes at https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/storage-optimized-instances.html#i2-instances-diskperf . Many AWS customers use these instances for high IOPS sensitive applictions like databases.

However instance store volumes are ephemeral. In order to ensure durability you need to be able to push the data on local SSD volumes to EBS on a regular basis. Throughput optimized HDD (st1) volumes ae a popular choice for this use case (https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSVolumeTypes.html). In the event of data loss due to loss of i3 instance you will need to restore data from your EBS volume to a new i3 instance store SSD.

Loading of this data from an st1 volume could be slow hampering RTO. One of myc ustomers was looking to reduce the time to restore.

Reading for st1 volumes for restoring to instance store is a read heavy operation and can benefit from increasing the read-ahead setting. You can find more details on how to do it at https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSPerformance.html

I ran a test and was able to improve the performance by ~2.5 times. Look at the result of the test that I performed. 
<table>
    <tr>
        <td>Source</td>
        <td>Target</td>
        <td>Size (GB)</td>
        <td>Time taken (sec)</td>
        <td>Time taken (min)</td>
        <td>Throughput (MB/Sec)</td>
        <td>Read Ahead configuration</td>
    </tr>
    <tr>
        <td>st1</td>
        <td>ssd</td>
        <td>1000</td>
        <td>8025</td>
        <td>133.75</td>
        <td>128</td>
        <td>sudo blockdev --report /dev/nvme10n1<br>
RO    RA   SSZ   BSZ   StartSec            Size   Device<br>
rw   256   512   512          0  10737418240000   /dev/nvme10n1</td>
    </tr>
    <tr>
        <td>st1</td>
        <td>ssd</td>
        <td>1000</td>
        <td>3297</td>
        <td>54.95</td>
        <td>311</td>
        <td>sudo blockdev --setra 2048 /dev/nvme10n1<br>
sudo blockdev --report /dev/nvme10n1<br>
RO    RA   SSZ   BSZ   StartSec            Size   Device<br>
rw  2048   512   512          0  10737418240000   /dev/nvme10n1</td>
    </tr>
</table>



# Comments

<div id="commento"></div>
<script src="https://cdn.commento.io/js/commento.js"></script>