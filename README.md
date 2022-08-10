# Introduction 
In this build we will be utilizing AWS to run our Python Flask application.  

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
Lets setup our app environment. We will be creating a key pair, VPC, subnet, internet gateway, route table, security group, and our EC2 instance.

### Step 3.1
Lets create a key pair
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-key-pair.html#examples
aws ec2 create-key-pair \
--key-name MyKeyPair \
--query 'KeyMaterial' \
--tag-specifications 'ResourceType=key-pair,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=davisdre@hotmail.com}]' \
--output text > MyKeyPair.pem
```

### Step 3.2
Lets create a VPC
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-vpc.html#examples
aws ec2 create-vpc \
--cidr-block 10.0.0.0/16 \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=davisdre@hotmail.com}]'
```

### Step 3.3
Lets create a subnet for our VPC.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-subnet.html#examples
aws ec2 create-subnet \
--vpc-id vpc-03e881f0e63745a53 \
--cidr-block 10.0.0.0/24 \
--tag-specifications 'ResourceType=subnet,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=davisdre@hotmail.com}]'
```

### Step 3.4
Let's create a internet gateway so we can access our app from the internet.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-internet-gateway.html#examples
aws ec2 create-internet-gateway \
--tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=davisdre@hotmail.com}]'
```

### Step 3.5
Let's connect our VPC to our Internet gateway.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/attach-internet-gateway.html#examples
aws ec2 attach-internet-gateway \
--internet-gateway-id igw-06c2de67941e0c125 \
--vpc-id vpc-03e881f0e63745a53
```

### Step 3.6
In our route table lets create a route to the internet gateway.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route.html#examples
aws ec2 create-route \
--route-table-id rtb-068a2b7da4d4a107b \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id igw-06c2de67941e0c125
```

### Step 3.7
Lets associate our subnet to our route table.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/associate-route-table.html#examples
aws ec2 associate-route-table \
--route-table-id rtb-068a2b7da4d4a107b \
--subnet-id subnet-0ade94413dcccde42
```

### Step 3.8
Lets create a security group for our VPC.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-security-group.html#examples
aws ec2 create-security-group \
--group-name MyBuild2SecurityGroup \
--description "MyBuild2 security group" \
--vpc-id vpc-03e881f0e63745a53
```

### Step 3.9
Lets add some inbound rules in our security group for SSH and HTTP.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/authorize-security-group-ingress.html#examples
# Lets open port 22 for SSH. 
aws ec2 authorize-security-group-ingress \
--group-id sg-01fb8694664eda51c \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

# Lets open port 80 for http.
aws ec2 authorize-security-group-ingress \
--group-id sg-01fb8694664eda51c \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0
```

### Step 3.10
Now lets get our ec2 setup. 

Lets create our ec2 instance.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/run-instances.html#examples
aws ec2 run-instances \
--image-id ami-090fa75af13c156b4 \
--instance-type t2.micro \
--subnet-id subnet-0ade94413dcccde42 \
--security-group-ids sg-01fb8694664eda51c \
--associate-public-ip-address \
--key-name MyKeyPair \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=davisdre@hotmail.com}]'
```

Lets get the public IP of our instance.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instances.html#examples
aws ec2 describe-instances \
--instance-ids i-09216cc090c66f4e2 \
--query "Reservations[*].Instances[*].PublicIpAddress" \
--output text
```

Lets check if the instance is running.
``` bash
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instance-status.html#examples
aws ec2 describe-instance-status \
--instance-id i-09216cc090c66f4e2
```

## Step 4
If everything was setup correctly, we should be able to SSH into our ec2 so we can setup/install our web app on the ec2.

### Step 4.1
Lets SSH into our ec2.
``` bash
ssh MyKeyPair.pem ec2-user@123.456.789.0
```

### Step 4.1
