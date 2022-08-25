# Create key pair and store in a variable
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-ec2-keypairs.html
$tagEC2KeyPair1 = New-Object Amazon.EC2.Model.Tag; $tagEC2KeyPair1.Key = "Application-Name"; $tagEC2KeyPair1.Value = "myBuild2"
$tagEC2KeyPair2 = New-Object Amazon.EC2.Model.Tag; $tagEC2KeyPair2.Key = "Resource-Owner"; $tagEC2KeyPair2.Value = "your-email-here"
$tagSpecEC2KeyPair = New-Object Amazon.EC2.Model.TagSpecification; $tagSpecEC2KeyPair.ResourceType = "key-pair"; $tagSpecEC2KeyPair.Tags.Add($tagEC2KeyPair1); $tagSpecEC2KeyPair.Tags.Add($tagEC2KeyPair2)
$myBuild2KeyPair = New-EC2KeyPair -KeyName myBuild2KeyPair
# Store the private key to a file
$myBuild2KeyPair.KeyMaterial | Out-File -Encoding ascii myBuild2KeyPair.pem

# Create a VPC
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Vpc.html&tocid=New-EC2Vpc
$tagEC2Vpc1 = New-Object Amazon.EC2.Model.Tag; $tagEC2Vpc1.Key = "Application-Name"; $tagEC2Vpc1.Value = "myBuild2"
$tagEC2Vpc2 = New-Object Amazon.EC2.Model.Tag; $tagEC2Vpc2.Key = "Resource-Owner"; $tagEC2Vpc2.Value = "your-email-here"
$tagSpecEC2Vpc = New-Object Amazon.EC2.Model.TagSpecification; $tagSpecEC2Vpc.ResourceType = "vpc"; $tagSpecEC2Vpc.Tags.Add($tagEC2Vpc1); $tagSpecEC2Vpc.Tags.Add($tagEC2Vpc2)
New-EC2Vpc -CidrBlock 10.0.0.0/16 -TagSpecification $tagSpecEC2Vpc

# Create a subnet
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Subnet.html&tocid=New-EC2Subnet
$tagEC2Subnet1 = New-Object Amazon.EC2.Model.Tag; $tagEC2Subnet1.Key = "Application-Name"; $tagEC2Subnet1.Value = "myBuild2"
$tagEC2Subnet2 = New-Object Amazon.EC2.Model.Tag; $tagEC2Subnet2.Key = "Resource-Owner"; $tagEC2Subnet2.Value = "your-email-here"
$tagSpecEC2Subnet = New-Object Amazon.EC2.Model.TagSpecification; $tagSpecEC2Subnet.ResourceType = "subnet"; $tagSpecEC2Subnet.Tags.Add($tagEC2Subnet1); $tagSpecEC2Subnet.Tags.Add($tagEC2Subnet2)
New-EC2Subnet -VpcId vpc-123 -CidrBlock 10.0.0.0/24 -TagSpecification $tagSpecEC2Subnet

# Create a internet gateway
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2InternetGateway.html&tocid=New-EC2InternetGateway
$tagEC2InternetGateway1 = New-Object Amazon.EC2.Model.Tag; $tagEC2InternetGateway1.Key = "Application-Name"; $tagEC2InternetGateway1.Value = "myBuild2"
$tagEC2InternetGateway2 = New-Object Amazon.EC2.Model.Tag; $tagEC2InternetGateway2.Key = "Resource-Owner"; $tagEC2InternetGateway2.Value = "your-email-here"
$tagSpecEC2InternetGateway = New-Object Amazon.EC2.Model.TagSpecification; $tagSpecEC2InternetGateway.ResourceType = "internet-gateway"; $tagSpecEC2InternetGateway.Tags.Add($tagEC2InternetGateway1); $tagSpecEC2InternetGateway.Tags.Add($tagEC2InternetGateway2)
New-EC2InternetGateway -TagSpecification $tagSpecEC2InternetGateway

# Attach internet gateway to VPC
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=Add-EC2InternetGateway.html&tocid=Add-EC2InternetGateway
Add-EC2InternetGateway -InternetGatewayId igw-123 -VpcId vpc-123

# Lets create a route to the internet gateway
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Route.html&tocid=New-EC2Route
New-EC2Route -RouteTableId rtb-123 -DestinationCidrBlock 0.0.0.0/0 -GatewayId igw-123

# Assocate subnet to route table.
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=Register-EC2RouteTable.html&tocid=Register-EC2RouteTable
Register-EC2RouteTable -RouteTableId rtb-123 -SubnetId subnet-123

# Lets get our security group setup and add some inbound ports, 22 and 80.
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-ec2-sg.html#new-ec2securitygroup-vpc
# lets create a security group and specify a variable as well to help with adding ports later.
$tagEC2SecurityGroup1 = New-Object Amazon.EC2.Model.Tag; $tagEC2SecurityGroup1.Key = "Application-Name"; $tagEC2SecurityGroup1.Value = "myBuild2"
$tagEC2SecurityGroup2 = New-Object Amazon.EC2.Model.Tag; $tagEC2SecurityGroup2.Key = "Resource-Owner"; $tagEC2SecurityGroup2.Value = "your-email-here"
$tagSpecEC2SecurityGroup = New-Object Amazon.EC2.Model.TagSpecification; $tagSpecEC2SecurityGroup.ResourceType = "security-group"; $tagSpecEC2SecurityGroup.Tags.Add($tagEC2SecurityGroup1); $tagSpecEC2SecurityGroup.Tags.Add($tagEC2SecurityGroup2)
$groupid = New-EC2SecurityGroup -VpcId vpc-123 -GroupName "myBuild2SecurityGroup" -GroupDescription "Security group for my build2" -TagSpecification $tagSpecEC2SecurityGroup
# lets add our inbound rules for port 22 and 80.
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=Grant-EC2SecurityGroupIngress.html&tocid=Grant-EC2SecurityGroupIngress
$ip1 = new-object Amazon.EC2.Model.IpPermission 
$ip1.IpProtocol = "tcp" 
$ip1.FromPort = 22 
$ip1.ToPort = 22 
$ip1.IpRanges.Add("0.0.0.0/0") 
$ip2 = new-object Amazon.EC2.Model.IpPermission 
$ip2.IpProtocol = "tcp" 
$ip2.FromPort = 80 
$ip2.ToPort = 80 
$ip2.IpRanges.Add("0.0.0.0/0") 
Grant-EC2SecurityGroupIngress -GroupId $groupid -IpPermissions @( $ip1, $ip2 )

# Create a EC2 instance
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Instance.html&tocid=New-EC2Instance
# Lets find us a EC2 image to use. Easy way to do this is just to look in the web consle to see latest AMI ID.
# Lets create a ec2 instance in our VPC
$tagEC2Instance1 = New-Object Amazon.EC2.Model.Tag; $tagEC2Instance1.Key = "Application-Name"; $tagEC2Instance1.Value = "myBuild2"
$tagEC2Instance2 = New-Object Amazon.EC2.Model.Tag; $tagEC2Instance2.Key = "Resource-Owner"; $tagEC2Instance2.Value = "your-email-here"
$tagSpecEC2Instance = New-Object Amazon.EC2.Model.TagSpecification; $tagSpecEC2Instance.ResourceType = "instance"; $tagSpecEC2Instance.Tags.Add($tagEC2Instance1); $tagSpecEC2Instance.Tags.Add($tagEC2Instance2)
New-EC2Instance -ImageId ami-05fa00d4c63e32376 -InstanceType t2.micro -KeyName myBuild2KeyPair -SecurityGroupId sg-123 -SubnetId subnet-123 -AssociatePublicIp $true -TagSpecification $tagSpecEC2Instance