#!/bin/bash
TEMPRANDSTR=
function getRandPassword
{
    dd if=/dev/urandom bs=8 count=1 of=/tmp/randpasswdtmpfile >/dev/null 2>&1
    TEMPRANDSTR=`cat /tmp/randpasswdtmpfile`
    rm /tmp/randpasswdtmpfile
    local DATE=`date`
    TEMPRANDSTR=`echo "$TEMPRANDSTR$RANDOM$DATE" |  md5sum | base64 | head -c 16`
}
getRandPassword
ROOTSQLPWD=$TEMPRANDSTR
USERSQLPWD=$TEMPRANDSTR

#Create Database
/etc/init.d/mysql start
mysql -v -e "create database wp_ls;grant all on wp_ls.* to wp_ls@localhost identified by '$USERSQLPWD'"

#update mysql root pass
mysql -uroot -v -e "use mysql;update user set Password=PASSWORD('$ROOTSQLPWD') where user='root'; flush privileges;"

#Install wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
wp package install aaemnnosttv/wp-cli-dotenv-command:^1.0

#Install php-cli
yum install -y php-cli php-zip wget unzip

#Install composer php
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

#Install node.js and npm
yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_6.x
yum install -y nodejs


#
# Install and Config Bedrock and Sage
#
project=${project:=project}
db_username=${db_username:=wp-ls}
db_password=$USERSQLPWD
db_host=${db_host:=localhost}
db_name=${project:=wp_ls}
wp_home=$project.dev  #change .dev to .localhost or whatever you're using
wp_username=${wp_username:=admin}
wp_password=${wp_password:=admin}
wp_email=${wp_host:=dev@bvisible.dev}

# Setup Bedrock
cd /home/defdomain/html/
$composer create-project roots/bedrock .

# Setup Env
wp dotenv init
wp dotenv salts generate

# Create DB
wp db create

# Run WordPress Install
wp core install --title=Bedrock --admin_user=$wp_username --admin_password=$wp_password --admin_email=$wp_email --url=$wp_home

# Setup WordPress Options
wp option update blogdescription ''
wp option update start_of_week 0
wp option update permalink_structure '/%postname%'
wp rewrite flush

# Remove WordPress Default Posts
wp post delete 1 --force
wp post delete 2 --force

# Remove WordPress Default Themes
#wp theme delete twentyten
#wp theme delete twentyeleven
#wp theme delete twentytwelve
#wp theme delete twentythirteen
#wp theme delete twentyfourteen
rm -rf $(pwd)/web/wp/wp-content/themes/twentyten
rm -rf $(pwd)/web/wp/wp-content/themes/twentyeleven
rm -rf $(pwd)/web/wp/wp-content/themes/twentytwelve
rm -rf $(pwd)/web/wp/wp-content/themes/twentythirteen
rm -rf $(pwd)/web/wp/wp-content/themes/twentyfourteen
rm -rf $(pwd)/web/wp/wp-content/themes/twentyfifteen

# Create Homepage
wp post create --post_type=page --post_status=publish --post_title="Home"
wp option update show_on_front 'page'

# Install Plugins
$composer require wpackagist-plugin/disable-comments
wp plugin activate disable-comments
$composer require soberwp/intervention
wp plugin activate intervention

#
# Setup Sage
#
$composer create-project roots/sage web/app/themes/sage
replace "bedrock" "sage" -- assets/config.json
git init
git add .
git commit -m "Init"

npm install

npm run build

wp theme activate sage

chown -R nobody:nobody /home/defdomain/html

#Install nano
yum install -y nano

#Install php72
yum install -y epel-release
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install -y yum-utils
yum-config-manager --enable remi-php72
yum update -y 
yum install -y php72
yum install -y php72-php-fpm php72-php-gd php72-php-json php72-php-mbstring php72-php-mysqlnd php72-php-xml php72-php-xmlrpc php72-php-opcache
yum --enablerepo=remi-php72 install -y php-xml php-soap php-xmlrpc php-mbstring php-json php-gd php-mcrypt

#Install dev tools for openlitespeed
yum groupinstall -y "Development Tools"
yum install -y libxml2-devel openssl-devel curl-devel libpng* 

#Delete Install file
rmdir wordpress
rm latest.tar.gz
rm /tmp/wp.keys