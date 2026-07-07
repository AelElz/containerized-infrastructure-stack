FROM debian:bookworm

RUN apt update && apt install -y \
    php-fpm \
    php-mysqli \
    curl \
    mariadb-client

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/.
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh

RUN mkdir /run/mysqld && chmod +x /usr/local/bin/wp-setup.sh

CMD ["/usr/local/bin/wp-setup.sh"]
