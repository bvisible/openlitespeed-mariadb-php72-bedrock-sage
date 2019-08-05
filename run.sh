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
cd /usr/local/bin
php -d memory_limit=512M wp package install aaemnnosttv/wp-cli-dotenv-command:^1.0


#Install composer php
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Create Var
project=${project:=your_project}
db_username=${db_username:=wp_ls}
db_password=$USERSQLPWD
db_host=${db_host:=localhost}
db_name=${db_name:=wp_ls}
wp_home=$project.dev #change .dev to .localhost or whatever you're using
wp_username=${wp_username:=admin}
wp_password=${wp_password:=admin}
wp_email=${wp_host:=wordpress@project.dev}
current_path=$(pwd)

# Setup Bedrock
cd /home/defdomain/html/
composer create-project roots/bedrock .

# Setup Env
printf "\n${bold}Setup Env File:\n${normal}"
wp dotenv init
printf "DB_NAME=$db_name\nDB_USER=$db_username\nDB_PASSWORD=$db_password\nDB_HOST=$db_host\nWP_ENV=development\nWP_HOME=http://$wp_home/web\nWP_SITEURL=http://$wp_home/web/wp" | tee ".env"
printf "\n"
wp dotenv salts generate

# Create DB
printf "\n${bold}Create Database:\n${normal}"
wp db create

# Run WordPress Install
printf "\n${bold}Run WordPress Install:\n${normal}"
wp core install --title=$project --admin_user=$wp_username --admin_password=$wp_password --admin_email=$wp_email --url=$wp_home

# Setup WordPress Options
printf "\n${bold}Update Defaults:\n${normal}"
wp option update blogdescription ''
wp option update start_of_week 0
wp option update timezone_string 'Africa/Johannesburg'
wp option update permalink_structure '/%postname%'
wp rewrite flush

# Remove WordPress Default Posts
printf "\n${bold}Remove Default Posts:\n${normal}"
wp post delete 1 --force
wp post delete 2 --force

# Remove WordPress Default Themes
printf "\n${bold}Remove Default Themes:\n${normal}"
#wp theme delete twentyten
#wp theme delete twentyeleven
#wp theme delete twentytwelve
#wp theme delete twentythirteen
#wp theme delete twentyfourteen
rm -rf /home/defdomain/html/web/wp/wp-content/themes/twentyseventeen
rm -rf /home/defdomain/html/web/wp/wp-content/themes/twentysixteen

rm -rf /home/defdomain/html/web/app/themes/twentyseventeen
rm -rf /home/defdomain/html/web/spp/themes/twentysixteen
printf "${bold}Success:${normal} Deleted themes.\n"

# Create Homepage
printf "\n${bold}Create Homepage:\n${normal}"
wp post create --post_type=page --post_status=publish --post_title="Home"
wp option update show_on_front 'page'

# Install Plugins
printf "\n${bold}Install Plugins:\n${normal}"
composer require wpackagist-plugin/disable-comments
wp plugin activate disable-comments
wp plugin instal litespeed-cache --activate
wp plugin activate intervention
composer require roots/soil
wp plugin activate soil

#
# Setup Sage
#
printf "\n${bold}── Sage9 ── \n${normal}"
cd /home/defdomain/html/web/app/themes
composer create-project roots/sage
cd /home/defdomain/html/web/app/themes/sage
replace "bedrock" "sage" -- resources/assets/config.json
git init
git add .
git commit -m "Init"

printf "Run NPM Install:\n"
npm install

printf "Run NPM Build:\n"
npm run build

printf "Activate Sage:\n"
wp theme activate Sage Starter Theme

chown -R nobody:nobody /home/defdomain/html