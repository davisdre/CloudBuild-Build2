# Create key pair and store in a variable
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-ec2-keypairs.html
$myBuild2KeyPair = New-EC2KeyPair -KeyName myBuild2KeyPair
# Store the private key to a file
$myBuild2KeyPair.KeyMaterial | Out-File -Encoding ascii myBuild2KeyPair.pem

# Create a VPC
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Vpc.html&tocid=New-EC2Vpc
$tagEC2Vpc1 = New-Object Amazon.EC2.Model.Tag; $tagEC2Vpc1.Key = "Application-Name"; $tagEC2Vpc1.Value = "myBuild2"
$tagEC2Vpc2 = New-Object Amazon.EC2.Model.Tag; $tagEC2Vpc2.Key = "Resource-Owner"; $tagEC2Vpc2.Value = "davisdre@hotmail.com"
$tagSpecEC2Vpc = New-Object Amazon.EC2.Model.TagSpecification; $tagSpecEC2Vpc.ResourceType = "vpc"; $tagSpecEC2Vpc.Tags.Add($tagEC2Vpc1); $tagSpecEC2Vpc.Tags.Add($tagEC2Vpc2)
New-EC2Vpc -CidrBlock 10.0.0.0/16 -TagSpecification $tagSpec

# Create a subnet
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Subnet.html&tocid=New-EC2Subnet
$tagEC2Subnet1 = New-Object Amazon.EC2.Model.Tag; $tagEC2Subnet1.Key = "Application-Name"; $tagEC2Subnet1.Value = "myBuild2"
$tagEC2Subnet2 = New-Object Amazon.EC2.Model.Tag; $tagEC2Subnet2.Key = "Resource-Owner"; $tagEC2Subnet2.Value = "davisdre@hotmail.com"
$tagSpecEC2Subnet = New-Object Amazon.EC2.Model.TagSpecification; $tagSpecEC2Subnet.ResourceType = "subnet"; $tagSpecEC2Subnet.Tags.Add($tagEC2Subnet1); $tagSpecEC2Subnet.Tags.Add($tagEC2Subnet2)
New-EC2Subnet -VpcId vpc-05b72a92d78ea44c4 -CidrBlock 10.0.0.0/24 -TagSpecification $tagSpecEC2Subnet

# Create a internet gateway
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Vpc.html&tocid=New-EC2Vpc
New-EC2InternetGateway

# Attach internet gateway to VPC
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Vpc.html&tocid=New-EC2Vpc
Add-EC2InternetGateway -InternetGatewayId igw-047ffcc0c47b86270 -VpcId vpc-0aa729b5b433170be

# Lets create a route to the internet gateway
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Route.html&tocid=New-EC2Route
New-EC2Route -RouteTableId rtb-083ef49ceccda5e90 -DestinationCidrBlock 0.0.0.0/0 -GatewayId igw-047ffcc0c47b86270

# Assocate subnet to route table.
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=Register-EC2RouteTable.html&tocid=Register-EC2RouteTable
Register-EC2RouteTable -RouteTableId rtb-083ef49ceccda5e90 -SubnetId subnet-0ad44a198b120bf84

# Lets get our security group setup and add some inbound ports, 22 and 80.
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-ec2-sg.html#new-ec2securitygroup-vpc
# lets create a security group and specify a variable as well to help with adding ports later.
$groupid = New-EC2SecurityGroup -VpcId vpc-0aa729b5b433170be -GroupName "myBuild2SecurityGroup" -GroupDescription "Security group for my build2"
# lets add our inbound rules for port 22 and 80.
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
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-ec2-get-amis.html#pstools-ec2-get-ec2imagebyname
# Lets find us a EC2 image to use. Easy way to do this is just to look in the web consle to see latest AMI ID.
# Lets create a ec2 instance in our VPC
New-EC2Instance -ImageId ami-051dfed8f67f095f5 -InstanceType t2.micro -KeyName myBuild2KeyPair -SecurityGroupId sg-03a0ecfdb3b7ab0d8 -SubnetId subnet-0ad44a198b120bf84 -AssociatePublicIp $true