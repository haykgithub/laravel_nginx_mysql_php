#!/bin/bash

# https://www.digitalocean.com/community/tutorials/how-to-set-up-laravel-nginx-and-mysql-with-docker-compose

# Go home
cd ~

# clone the latest Laravel release to a directory called laravel-app
git clone https://github.com/laravel/laravel.git laravel-app

# Go to laravel-app folder
cd ~/laravel-app

# Use Docker’s composer image to mount the directories that you will need for your Laravel project and avoid the overhead of installing Composer globally

# Using the -v and --rm flags with docker run creates an ephemeral container that will be bind-mounted to your current directory before being removed. This will copy the contents of your ~/laravel-app directory to the container and also ensure that the vendor folder Composer creates inside the container is copied to your current directory.
docker run --rm -v $(pwd):/app composer install

# Set permissions on the project directory so that it is owned by your non-root user
sudo chown -R $USER:$USER ~/laravel-app

# Download all configs in "tmp" from github.com
git clone https://github.com/haykgithub/laravel_nginx_mysql_php.git tmp

# Copy "Dockerfile" and "docker-compose.yml" from ~/laravel-app/tmp to ~/laravel-app/
cp ~/laravel-app/tmp/Dockerfile ~/laravel-app/Dockerfile
###cp ~/laravel-app/tmp/docker-compose.yml ~/laravel-app/docker-compose.yml
cp ~/laravel-app/tmp/docker-compose.yml_with_persisting_data ~/laravel-app/docker-compose.yml

# Create the php directory
mkdir -p ~/laravel-app/php

# Copy ~/laravel-app/tmp/local.ini to ~/laravel-app/php/local.ini
cp ~/laravel-app/tmp/local.ini ~/laravel-app/php/local.ini

# Create the nginx/conf.d/ directory
mkdir -p ~/laravel-app/nginx/conf.d

# Copy app.conf from ~/laravel-app/tmp to ~/laravel-app/nginx/conf.d
cp ~/laravel-app/tmp/app.conf ~/laravel-app/nginx/conf.d/app.conf

# Create the mysql directory
mkdir -p ~/laravel-app/mysql

# Copy ~/laravel-app/tmp/my.cnf ~/laravel-app/mysql/my.cnf
cp ~/laravel-app/tmp/my.cnf ~/laravel-app/mysql/my.cnf

# Copy env from ~/laravel-app/tmp to ~/laravel-app/.env
cp ~/laravel-app/tmp/env ~/laravel-app/.env

# Boil the configs
docker-compose up -d

# Show containers
docker ps -a

# The following command will generate a key and copy it to your .env file, ensuring that your user sessions and encrypted data remain secure
docker-compose exec app php artisan key:generate

# You now have the environment settings required to run your application. To cache these settings into a file, which will boost your application’s load speed, run
docker-compose exec app php artisan config:cache
