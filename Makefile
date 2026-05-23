COMPOSE_FILE = srcs/docker-compose.yml

all: makedirs
	docker compose -f $(COMPOSE_FILE) up --build -d

down:
	docker compose -f $(COMPOSE_FILE) down

re: fclean all

clean: down
	docker system prune -f

fclean: clean
	docker volume prune -f
	docker image prune -af

logs:
	docker compose -f $(COMPOSE_FILE) logs

status:
	docker ps

.PHONY: all makedirs down re clean fclean logs status
