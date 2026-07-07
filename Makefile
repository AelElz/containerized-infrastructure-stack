COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/ael-azha/data

all: makedirs
	docker compose -f $(COMPOSE_FILE) up --build -d

makedirs:
	mkdir -p $(DATA_DIR)/wordpress
	mkdir -p $(DATA_DIR)/mariadb

down:
	docker compose -f $(COMPOSE_FILE) down

re: fclean all

clean: down
	docker system prune -f

fclean: clean
	sudo rm -rf $(DATA_DIR)/wordpress/*
	sudo rm -rf $(DATA_DIR)/mariadb/*
	docker volume prune -f
	docker image prune -af

logs:
	docker compose -f $(COMPOSE_FILE) logs

status:
	docker ps

.PHONY: all makedirs down re clean fclean logs status
