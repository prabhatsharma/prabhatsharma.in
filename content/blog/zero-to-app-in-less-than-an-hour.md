---
title: "Zero to App in Less Than an Hour"
date: 2020-04-23T08:09:57-07:00
draft: true
# image: images/blog/car/car2.jpg
tags: ["architecture", "beautiful", "old", "nostalgia" ]
author: Prabhat Sharma
type: post
---



vue create todo

cd todo


npm install aws-amplify @aws-amplify/ui-vue --save

setup front end - https://docs.amplify.aws/start/getting-started/setup/q/integration/vue#install-amplify-libraries

modify main.js

import Amplify from 'aws-amplify';
import '@aws-amplify/ui-vue';
import aws_exports from './aws-exports';

Amplify.configure(aws_exports);


amplify init



amplify add auth

Using service: Cognito, provided by: awscloudformation
 
 The current configured provider is Amazon Cognito. 
 
 Do you want to use the default authentication and security configuration? Default configuration with Social Provider (Federation)
 Warning: you will not be able to edit these selections. 
 How do you want users to be able to sign in? Email
 Do you want to configure advanced settings? No, I am done.
 What domain name prefix you want us to create for you? todo1682960f-1682960f
 Enter your redirect signin URI: http://localhost:8080/signin/
? Do you want to add another redirect signin URI No
 Enter your redirect signout URI: http://localhost:8080/signout/
? Do you want to add another redirect signout URI No
 Select the social providers you want to configure for your user pool: Facebook, Google
  
 You've opted to allow users to authenticate via Facebook.  If you haven't already, you'll need to go to https://developers.facebook.com and create an App ID
. 
 
 Enter your Facebook App ID for your OAuth flow:  
 Enter your Facebook App Secret for your OAuth flow:  
  
 You've opted to allow users to authenticate via Google.  If you haven't already, you'll need to go to https://developers.google.com/identity and create an A
pp ID. 
 
 Enter your Google Web Client ID for your OAuth flow:  
 Enter your Google Web Client Secret for your OAuth flow:  
Successfully added resource todo1682960f locally

Some next steps:
"amplify push" will build all your local backend resources and provision it in the cloud
"amplify publish" will build all your local backend and frontend resources (if you have hosting category added) and provision it in the cloud



amplify push

configure facebook and google auth

amplify add api

(base) prabhsha@f8ffc2014a6a:~/projects/aws/todo$ amplify add api
? Please select from one of the below mentioned services: GraphQL
? Provide API name: todo
? Choose the default authorization type for the API Amazon Cognito User Pool
Use a Cognito user pool configured as a part of this project.
? Do you want to configure advanced settings for the GraphQL API No, I am done.
? Do you have an annotated GraphQL schema? No
? Do you want a guided schema creation? Yes
? What best describes your project: Single object with fields (e.g., “Todo” with ID, name, description)
? Do you want to edit the schema now? Yes
Please edit the file in your editor: /Users/prabhsha/projects/aws/todo/amplify/backend/api/todo/schema.graphql
? Press enter to continue 

The following types do not have '@auth' enabled. Consider using @auth with @model
         - Todo
Learn more about @auth here: https://aws-amplify.github.io/docs/cli-toolchain/graphql#auth 


GraphQL schema compiled successfully.

Edit your schema at /Users/prabhsha/projects/aws/todo/amplify/backend/api/todo/schema.graphql or place .graphql files in a directory at /Users/prabhsha/projects/aws/todo/amplify/backend/api/todo/schema
Successfully added resource todo locally

Some next steps:
"amplify push" will build all your local backend resources and provision it in the cloud
"amplify publish" will build all your local backend and frontend resources (if you have hosting category added) and provision it in the cloud


configure auth for graohql api
.////


amplify push


Connect to the API 
https://docs.amplify.aws/start/getting-started/data-model/q/integration/vue



amplify add hosting
