# Resources
https://cloudaffaire.com/how-to-create-an-aws-ec2-instance-using-aws-cli/
https://help.acloud.guru/hc/en-us/articles/360001389256?_ga=2.222229336.1776338761.1659543097-734359405.1648734366


# Lets create a key pair
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-key-pair.html#examples
aws ec2 create-key-pair \
--key-name MyKeyPair \
--query 'KeyMaterial' \
--tag-specifications 'ResourceType=key-pair,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=email@domain.com}]' \
--output text > MyKeyPair.pem


# Lets create a VPC
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-vpc.html#examples
aws ec2 create-vpc \
--cidr-block 10.0.0.0/16 \
--tag-specifications 'ResourceType=vpc,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=email@domain.com}]'


# Lets create a subnet
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-subnet.html#examples
aws ec2 create-subnet \
--vpc-id vpc-123 \
--cidr-block 10.0.0.0/24 \
--tag-specifications 'ResourceType=subnet,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=email@domain.com}]'

# Lets create a internet gateway
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-internet-gateway.html#examples
aws ec2 create-internet-gateway \
--tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=email@domain.com}]'

# Lets connect our VPC to our Internet gateway
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/attach-internet-gateway.html#examples
aws ec2 attach-internet-gateway \
--internet-gateway-id igw-123 \
--vpc-id vpc-123

# Lets create a route to the Internet Gateway in our route table
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-route.html#examples
aws ec2 create-route \
--route-table-id rtb-123 \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id igw-123

# Lets associate our subnet to route table
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/associate-route-table.html#examples
aws ec2 associate-route-table \
--route-table-id rtb-123 \
--subnet-id subnet-123

# Lets create a security group for our VPC.
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/create-security-group.html#examples
aws ec2 create-security-group \
--group-name MyBuild2SecurityGroup \
--description "MyBuild2 security group" \
--vpc-id vpc-123

# Lets create some inbound rules in our security group.
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/authorize-security-group-ingress.html#examples
# Lets open port 22 for SSH. 
aws ec2 authorize-security-group-ingress \
--group-id sg-123 \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0

# Lets open port 80 for http.
aws ec2 authorize-security-group-ingress \
--group-id sg-123 \
--protocol tcp \
--port 80 \
--cidr 0.0.0.0/0

# Now lets create our EC2 instance
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/run-instances.html#examples
aws ec2 run-instances \
--image-id ami-090fa75af13c156b4 \
--instance-type t2.micro \
--subnet-id subnet-123 \
--security-group-ids sg-123 \
--associate-public-ip-address \
--key-name MyKeyPair \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Application-Name,Value=MyCloudBuild2},{Key=Resource-Owner,Value=email@doamin.com}]'


# Lets get the public IP of our instance
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instances.html#examples
aws ec2 describe-instances \
--instance-ids i-123 \
--query "Reservations[*].Instances[*].PublicIpAddress" \
--output text

# Lets check if the instance is running.
# https://awscli.amazonaws.com/v2/documentation/api/latest/reference/ec2/describe-instance-status.html#examples
aws ec2 describe-instance-status \
--instance-id i-123