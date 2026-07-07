PURPLE	= \033[0;35m
RED	= \033[0;31m
GREEN	= \033[0;32m
YELLOW	= \033[0;33m
BLUE	= \033[0;34m
MAGENTA	= \033[0;35m
CYAN	= \033[0;36m
RESET	= \033[0m
BOLD	= \033[1m

SHELL		= /bin/bash
COMPOSE_FILE	= srcs/docker-compose.yml
DATA_DIR	= /home/ael-azha/data
DOCKER_COMPOSE	= docker compose -f $(COMPOSE_FILE)

.DEFAULT_GOAL := up

up:
	@echo -e "$(CYAN)$(BOLD)Starting services...$(RESET)"
	@mkdir -p $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb
	@$(DOCKER_COMPOSE) up --build -d
	@echo -e "$(GREEN)✓ Services started successfully$(RESET)"

down:
	@$(DOCKER_COMPOSE) down

clean: down
	@docker system prune -f

fclean: clean
	@sudo rm -rf $(DATA_DIR)/wordpress/* $(DATA_DIR)/mariadb/*
	@docker volume prune -f
	@docker image prune -af

.PHONY: up down clean fclean
