# Introduction 
In this build we will be utilizing AWS to run a WordPress application. You could use this as a website and/or blog.  

# Getting Started
The following will help you get started with this build:
1. Have either a [AWS free account](https://aws.amazon.com/free/free-tier/) OR A Cloud Guru account.
2. Have either the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed on your computer OR use the [AWS Cloud Shell](https://aws.amazon.com/cloudshell/).
3. Preferred for you to have either AWS CLI or AWS PowerShell installed on your computer.
4. Preferred if you have Visual Studio Code installed on your computer to work with the files easily. 

# Build and Test

## Step 1
Lets login to our AWS accounts. 

## Step 2
Lets setup our AWS Cloud Shell. 

## Step 3
Lets setup our app environment. We will be creating a key pair, VPC, subnet, internet gateway, route table, security group, and our EC2 instance.
Here you have two options, you can build via [AWS CLI](build.bash) or [AWS PowerShell](build2.ps1). 

## Step 4
If everything was setup correctly, we should be able to SSH into our ec2 so we can setup/install our web app on the ec2. NOTE, depening on how you setup you SSH key, you need to correct some of its permissions, ie. disable inheritance, make sure you are own and have full control. 

```
ssh -i .\myBuild2KeyPair.pem ec2-user@3.15.240.214
```

## Step 5
Lets setup our web app on our ec2.

``` bash
sudo yum update -y

sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

sudo yum install -y httpd mariadb-server

sudo systemctl start httpd

sudo systemctl enable httpd

# lets test to see we are good with apache running. go to browser, use public ip and lets see if you are good. 

sudo usermod -a -G apache ec2-user

exit

# log back in

#check if apache group was applied
groups

sudo chown -R ec2-user:apache /var/www

sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;

find /var/www -type f -exec sudo chmod 0664 {} \;

echo "<?php phpinfo(); ?>" > /var/www/html/phpinfo.php

# now go to web browser and see if you see http://publicip/phpinfo.php

# let remove phpinfo.php file
rm /var/www/html/phpinfo.php

sudo systemctl start mariadb

#lets secure our database with best practices
sudo mysql_secure_installation

sudo systemctl enable mariadb

# lets setup wordpress
wget https://wordpress.org/latest.tar.gz

tar -xzf latest.tar.gz

sudo systemctl start mariadb

#lets setup the database
mysql -u root -p

# commands inside the database to run.
CREATE USER 'user'@'localhost' IDENTIFIED BY '$tr0ngP@$$w0rd';

CREATE DATABASE `wordpress-db`;

GRANT ALL PRIVILEGES ON `wordpress-db`.* TO "user"@"localhost";

FLUSH PRIVILEGES;

exit

# configure wp-config.php file
cp wordpress/wp-config-sample.php wordpress/wp-config.php

# url to use to generate auth keys https://api.wordpress.org/secret-key/1.1/salt/
# save config file
nano wordpress/wp-config.php

# copy wordpress directory to root directory
cp -r wordpress/* /var/www/html/

sudo nano /etc/httpd/conf/httpd.conf

sudo yum install php-gd

sudo chown -R apache /var/www

sudo chgrp -R apache /var/www

sudo chmod 2775 /var/www

find /var/www -type d -exec sudo chmod 2775 {} \;

find /var/www -type f -exec sudo chmod 0644 {} \;

sudo systemctl restart httpd

sudo systemctl enable httpd && sudo systemctl enable mariadb

sudo systemctl status mariadb

sudo systemctl status httpd

# now go to your public ip in browser and complate wordpress setup
```

We should now be up and running!
![Capture1](/Capture1.PNG)

![Capture2](/Capture2.PNG)

![Capture3](/Capture3.PNG)