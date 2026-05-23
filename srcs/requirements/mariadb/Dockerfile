FROM debian:bookworm

RUN apt update && apt install -y mariadb-server

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY tools/init.sql /etc/mysql/init.sql

RUN mkdir /run/mysqld && chown -R mysql:mysql /run/mysqld

CMD ["mysqld"]
