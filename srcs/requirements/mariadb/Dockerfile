FROM debian:bookworm

RUN apt update && apt install -y mariadb-server

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/.
COPY tools/init-db.sh /usr/local/bin/init-db.sh

RUN mkdir /run/mysqld && chown -R mysql:mysql /run/mysqld && chmod +x /usr/local/bin/init-db.sh

CMD ["/usr/local/bin/init-db.sh"]
