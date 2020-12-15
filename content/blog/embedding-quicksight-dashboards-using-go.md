---
title: "Embedding Quicksight Dashboards Using Go"
date: 2020-09-24T10:00:28-07:00
draft: false
image: images/blog/quicksight.png
tags: ["quicksight", "analytics", "business intelligence", "amazon", "reporting", "aws"]
author: Prabhat Sharma
type: post
---

Amazon Quicksight is an amazingly simple Business Intelligence tool that is fully managed and allows one to get started with dashboarding and reporting in a matter of minutes. Its [dashboard embedding feature](https://docs.aws.amazon.com/quicksight/latest/user/embedded-dashboards-setup.html) is allows you to embed the dashboards natively in your web applications.

Essentially you have 3 steps to perform

1. Assume an IAM role (Let's call it *quicksight-embedded*) that has 2 required permissions:
    1. quicksight:RegisterUser
    1. quicksight:GetDashboardEmbedUrl

    For example you have your application running on an EC2 instance/Lambda/ECS Task that has the role *myAppIAMRole* . Your app needs to assume the quicksight-embedded role.

2. Register the user who will use the dashboard in quicksight. This is required as quicksight pricing is based on per user/session and provide a session name. If the user already exists then register user API will fail. Ideally you would want to register the user when user first accesses quicksight or you can pre-create the user in quicksight so you don't have to register them programmatically. Having users in quicksight does not cost you anything. It costs you only when they access the dashboards.

3. Call the GetDashboardEmbedUrl API and get the URL. The URL that you receive can be used only once.

We will perform all these 3 operations in Go.

## Step 1 - Assume the role

{{< highlight Go>}}

    //Create a session
	sess := session.Must(session.NewSession())

	// This is the IAM role that will be assumed for createing users. This should have the permission to call GetDashboardEmbedUrl
	// Also the user/role(could be an ec2 role, ecs task role or EKS pod role or lambda execution role) that is executing this go program must has the stsAssumeRole permission to assume the roleName
	roleName := "quicksight-embedded"
	awsAccountID := "107995894928"
	iamRoleARN := "arn:aws:iam::" + awsAccountID + ":role/" + roleName

	// Step 1 - AssumeRole
	creds := stscreds.NewCredentials(sess, iamRoleARN)
{{< / highlight >}}

This gives you the credentials of the assumed role.

## Step 2 - Register the user

{{< highlight Go>}}
    //Step 2: Register User. This might fail if user already exist, but no harm or foul if this fails due to UserAlready exists. Just continue
	client := quicksight.New(sess, &aws.Config{Credentials: creds, Region: &userRegistrationRegion})

	ruInput := quicksight.RegisterUserInput{
		AwsAccountId: &awsAccountID,
		Email:        &userEmail,
		IamArn:       &iamRoleARN,
		Namespace:    &namespace,
		IdentityType: &identityType,
		SessionName:  &userEmail,
		UserRole:     &userRole,
	}

	ruOutput, ruOutputError := client.RegisterUser(&ruInput)
	if ruOutputError != nil {
		fmt.Println(ruOutputError.Error())
	} else {
		fmt.Println(ruOutput.String())
	}

{{< / highlight >}}

## Step 3 - Get the dashboard URL

{{< highlight Go>}}
    dashboardID := "81d2ae9f-57bf-42b1-ad9e-9703718f36f6"
	userDashboardRegion := "us-west-2"

	// Need to create separate client since dashboard region could be different from us-east-1 which is the user region
	client2 := quicksight.New(sess, &aws.Config{Credentials: creds, Region: &userDashboardRegion})
	userARN := "arn:aws:quicksight:us-east-1:" + awsAccountID + ":user/" + namespace + "/" + roleName + "/" + userEmail

	dashboardIdentityType := "QUICKSIGHT"

	eURLInput := quicksight.GetDashboardEmbedUrlInput{
		AwsAccountId: &awsAccountID,
		DashboardId:  &dashboardID,
		IdentityType: &dashboardIdentityType, //Needs to be QUICKSIGHT here and not IAM even  though an IAM role is being used that assumes the role
		UserArn:      &userARN,
	}

	eURLOutput, errEmbed := client2.GetDashboardEmbedUrl(&eURLInput)

	if errEmbed != nil {
		fmt.Println("\nStep 3.2 - ", errEmbed.Error())
	} else {
		fmt.Println(eURLOutput)
	}

{{< / highlight >}}

The next part is to use the [quicksight embedding sdk](https://github.com/awslabs/amazon-quicksight-embedding-sdk) in your javascript app .

You can find the full Go code on [github](https://github.com/prabhatsharma/quicksightembedgo).

I hope this helps you.
