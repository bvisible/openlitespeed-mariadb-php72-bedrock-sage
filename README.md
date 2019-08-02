# Docker Bedrock + Sage with Centos7 Openlitespeed MariaDB10.2 ProFTPD PHP7.2

This Docker will run

- Centos 7
- Bedrock (roots.io)
- Sage (roots.io)
- Openlitespedd
- MariaDB10.2
- ProFTPD
- PHP 7.2
- WP CLI

you can access litespeed admin in http://your_project:7080, set password with command

```/usr/local/lsws/admin/misc/admpass.sh```

Document root in:
```
/home/defdomain/html/
```
## To finish the installation
```
nano /home/defdomain/html/.env
```
Change your_project to your local IP
```
## Build docker image
git clone https://github.com/bvisible/openlitespeed-mariadb-php72-bedrock-sage.git
cd openlitespeed-mariadb-php72-bedrock-sage
docker build --rm=true --no-cache=true -t openlitespeed-mariadb-php72-bedrock-sage .
```
Run docker image
```
docker run openlitespeed-mariadb-php72-bedrock-sage
```
## Hub Docker

Can found in https://hub.docker.com/r/bvisible/openlitespeed-mariadb-php72-bedrock-sage/

or pull
```
docker pull bvisible/openlitespeed-mariadb-php72-bedrock-sage/
```
```
thanks to tujuhion : https://github.com/tujuhion/docker-centos-openlitespeed-wordpress
thanks to darrenjacoby : https://github.com/darrenjacoby/bedrock-sage-bash-setup
thanks to Roots.io : https://roots.io/
```
