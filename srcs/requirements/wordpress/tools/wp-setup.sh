#!/bin/bash

chmod -R 777 /var/www/html
cd /var/www/html

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar

until mysql -h mariadb -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "SELECT 1;" > /dev/null 2>&1; do
    echo "Waiting for MariaDB..."
    sleep 2
done

./wp-cli.phar core download --allow-root
./wp-cli.phar config create \
    --dbname=${MYSQL_DATABASE} \
    --dbuser=${MYSQL_USER} \
    --dbpass=${MYSQL_PASSWORD} \
    --dbhost=mariadb \
    --allow-root

./wp-cli.phar core install \
    --url=${DOMAIN_NAME} \
    --title=inception \
    --admin_user=${WP_ADMIN_USER} \
    --admin_password=${WP_ADMIN_PASSWORD} \
    --admin_email=${WP_ADMIN_EMAIL} \
    --allow-root

./wp-cli.phar user create ${WP_USER} ${WP_USER_EMAIL} \
    --role=author \
    --user_pass=${WP_USER_PASSWORD} \
    --allow-root

php-fpm8.2 -F
