# Create key pair and store in a variable
# https://docs.aws.amazon.com/powershell/latest/userguide/pstools-ec2-keypairs.html
$myBuild2KeyPair = New-EC2KeyPair -KeyName myBuild2KeyPair
# Store the private key to a file
$myBuild2KeyPair.KeyMaterial | Out-File -Encoding ascii myBuild2KeyPair.pem

# Create a VPC
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=New-EC2Vpc.html&tocid=New-EC2Vpc
New-EC2Vpc -CidrBlock 10.0.0.0/16 -TagSpecification $tagspec1

$tag1 = @{ Key="Application-Name"; Value="MyCloudBuild2"}
$tagspec1 = new-object Amazon.EC2.Model.TagSpecification
$tagspec1.ResourceType = "vpc"
$tagspec1.Tags.Add($tag1)