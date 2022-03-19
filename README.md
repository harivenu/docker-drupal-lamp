# Docker Drupal LAMP

Docker LAMP for Drupal Project Development

* Apache 2.4.38(Debian)
* MySQL 8.0
* PhpMyAdmin 4.9.0.1
* PHP 7.4.28
* Drush 9.7.1
* Composer 1.9.0
* Memcached 3.1.3
* Mailhog (for catching the email from Drupal app)
* Drupal Console 1.9.3
* Drupal Check (https://github.com/mglaman/drupal-check/)
* xdebug 2.9.6 (Visual Studio Code)

# Usage

Install docker on your machine (instructions availabe in [docker](https://www.docker.com/products/docker-desktop)) also install git bash

```
git clone https://github.com/harivenu/docker-drupal-lamp.git

cd docker-drupal-lamp

docker-compose up -d
```

Open phpmyadmin at [http://localhost:8000](http://localhost:8000)
Open web browser to look at a simple php example at [http://localhost](http://localhost:8001) also Secure connection [https://localhost](https://localhost)

Place your Drupal code on [www](https://github.com/harivenu/docker-drupal-lamp/tree/master/www) directory it is already mount on apache container /var/www/html directory

You can aslo access your container with below command, container name you will get from `docker ps -a` command
```
docker exec -it <CONTAINTER NAME> bash
```

For MySQL
```
docker exec -it db mysql -u root -p
```
Credentials

Username : user
Password : test

Username : root
Password : test

For Mailhog access
Just visit - http://localhost:8025/

For Xdebug (Visual Studio Code)
Install PHP Debug extention then add launch.json to Visual Studio Code.

Enjoy..!!
