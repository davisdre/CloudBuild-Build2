# Introduction 
For our build we will create a Azure vm, install Docker, and run a Docker container for a website that we have created. 

# Getting Started
The following will help you get started with this build:
1. Have either a [AWS free account](https://aws.amazon.com/free/free-tier/) OR A Cloud Guru account.
2. Have either the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed on your computer OR use the [AWS Cloud Shell](https://aws.amazon.com/cloudshell/).

# Build and Test

## Step 1
Lets login to our AWS accounts. 

## Step 2
Lets setup our AWS Cloud Shell. 

## Step 3
Lets setup our environment. We will be creating a key pair, VPC, subnet, internet gateway, route table, security group, and our EC2 instance.

### Step 3.1
Lets create a key pair
``` bash
# Lets create a key pair
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-key-pair.html#examples
aws ec2 create-key-pair \
--key-name MyKeyPair \
--query 'KeyMaterial' \
--tag-specifications 'ResourceType=key-pair,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=davisdre@hotmail.com}]' \
--output text > MyKeyPair.pem
```