# Introduction 
In this build we will be utilizing AWS to run a WordPress application. You could use this as a website and/or blog.  

# Getting Started
The following will help you get started with this build:
1. Have either a [AWS free account](https://aws.amazon.com/free/free-tier/) OR A Cloud Guru account.
2. Have either the [AWS Powershell](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html) installed on your computer OR use the [AWS Cloud Shell](https://aws.amazon.com/cloudshell/).
3. **Preferred** for you to have AWS PowerShell installed on your computer.
4. **Preferred** if you have Visual Studio Code installed on your computer to work with the files easily. 

# Build and Test

## Step 1
Lets login to our AWS accounts whether that is your personal or via A Cloud Guru sandbox. Make sure you get your IAM credentials as we are building via the commandline.

``` bash
# setup aws credentials
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=Set-AWSCredential.html&tocid=Set-AWSCredential
Set-AWSCredential -AccessKey abcd -SecretKey abcd -StoreAs myBuild2Credentials
# now lets use those credentials
Set-AWSCredential -ProfileName myBuild2Credentials
# lets go ahead and set our default region as well
# https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=Set-DefaultAWSRegion.html&tocid=Set-DefaultAWSRegion
Set-DefaultAWSRegion -Region us-east-1
```

## Step 2
Lets setup our AWS Cloud Shell or open a terminal if have AWS Powershell install or AWS CLI. 

## Step 3
Lets setup our app environment. We will be creating a key pair, VPC, subnet, internet gateway, route table, security group, and our EC2 instance.
Here you have two options, you can build via [AWS CLI](./build.bash) or [AWS PowerShell](./build2.ps1). For this demostration I will walk you through using AWS PowerShell.

## Step 4
If everything was setup correctly, we should be able to SSH into our ec2 so we can setup/install our web app on the ec2. NOTE, depening on how you setup you SSH key, you need to correct some of its permissions, ie. disable inheritance, make sure you are owner and have full control to the .pem you created. 

```
ssh -i .\myBuild2KeyPair.pem ec2-user@3.15.240.214
```

## Step 5
Lets setup our web app on our ec2.

``` bash
# lets update the OS
sudo yum update -y
# lets install some software
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
# lets install some more software
sudo yum install -y httpd mariadb-server
# lets start httpd service
sudo systemctl start httpd
# lets make sure sure starts at restart
sudo systemctl enable httpd
```

Lets test to see we are good with apache running. go to browser, use public ip and lets see if you are good. ie. http://123.456.789.0

![Capture4](/Capture4.PNG)

Let's continune with our setup.
``` bash
# add ec2-user to apache group
sudo usermod -a -G apache ec2-user
# lets exit ssh session for permission changes to take affect.
exit
```

SSH back in to instance and lets continue with our setup.

``` bash
#check if apache group was applied. you should see 'apache' in the output.
groups
# lets apply some permissions
sudo chown -R ec2-user:apache /var/www

sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;

find /var/www -type f -exec sudo chmod 0664 {} \;
# Lets create a phpinfo.php page to display our php environment info.
echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php
```

Now go to web browser and see if you see http://123.456.789.0/phpinfo.php. If you see the new page, lets continue with our setup.

``` bash
# let remove phpinfo.php file
rm /var/www/html/phpinfo.php
# let start our database
sudo systemctl start mariadb
# lets secure our database with best practices: enter, Y, set a password, Y, Y, Y, Y
sudo mysql_secure_installation
# lets make sure the service starts after restart
sudo systemctl enable mariadb

# lets setup wordpress
# download latest wordpress version
wget https://wordpress.org/latest.tar.gz
# extract
tar -xzf latest.tar.gz
# lets just make sure database is still running.
sudo systemctl start mariadb

# lets setup the database. Use the password that you created earlier
mysql -u root -p

# commands inside the database to run.
CREATE USER 'wordpress-db-user'@'localhost' IDENTIFIED BY '$tr0ngP@$$w0rd';

CREATE DATABASE `wordpress-db`;

GRANT ALL PRIVILEGES ON `wordpress-db`.* TO "wordpress-db-user"@"localhost";

FLUSH PRIVILEGES;

exit

# configure wp-config.php file
# copy wp-config.php
cp wordpress/wp-config-sample.php wordpress/wp-config.php

# url to use to generate auth keys https://api.wordpress.org/secret-key/1.1/salt/ in the wp-config.php
nano wordpress/wp-config.php
```

![Capture5](/Capture5.PNG)

![Capture6](/Capture6.PNG)

``` bash
# copy wordpress directory to root directory
cp -r wordpress/* /var/www/html/
# Lets make a edit. Find the section that starts with <Directory "/var/www/html">. Change the AllowOverride None line in the above section to read AllowOverride All.
sudo nano /etc/httpd/conf/httpd.conf
# lets install some software
sudo yum install php-gd
#  lets make some permissions changes
sudo chown -R apache /var/www

sudo chgrp -R apache /var/www

sudo chmod 2775 /var/www

find /var/www -type d -exec sudo chmod 2775 {} \;

find /var/www -type f -exec sudo chmod 0644 {} \;
# lets restart our service httpd since we made some permission changes
sudo systemctl restart httpd
# lets make sure our services are set to start at reboot
sudo systemctl enable httpd && sudo systemctl enable mariadb
# lets make sure service is in a running state
sudo systemctl status mariadb
# lets make sure service is in a running state
sudo systemctl status httpd
```

Now go to your public ip in browser and complate wordpress setup. http://123.456.789.0

![Capture1](/Capture1.PNG)

![Capture2](/Capture2.PNG)

We should now be up and running!

![Capture3](/Capture3.PNG)