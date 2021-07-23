.PHONY: help \
build \
upd \
env \
composer-install \
npm-install \
npm-watch \
down

.DEFAULT_GOAL := help

# Set dir of Makefile to a variable to use later
MAKEPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PWD := $(dir $(MAKEPATH))

USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)

DOCKER_COMPOSE_YML=.docker/docker-compose.yml

help: ## * Show help (Default task)
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build services
	docker-compose -p yourdomain --f $(DOCKER_COMPOSE_YML) build

upd: ## Run containers in the background
	docker-compose -p yourdomain --f $(DOCKER_COMPOSE_YML) up -d

composer-install: ## Run composer command on a composer image based container (Install pacakges if you alread hav a composer.json file)
	docker run --rm -ti --user $(USER_ID):$(GROUP_ID) -v $(PWD):/app composer:2 composer install

composer-require: ## Run composer command on a composer image based container [make composer-require package="<vendor/package>"]
	docker run --rm -ti --user $(USER_ID):$(GROUP_ID) -v $(PWD):/app composer:2 composer require $(package)

composer-remove: ## Run composer command on a composer image based container [make composer-remove package="<vendor/package>"]
	docker run --rm -ti --user $(USER_ID):$(GROUP_ID) -v $(PWD):/app composer:2 composer remove $(package)

env: ## Create .env file
ifeq (,$(wildcard ./.env))
	docker exec --user $(USER_ID):$(GROUP_ID) -ti yourdomain-php-fpm cp .env.example .env
endif

npm-install: ## Install node packages
	docker run -ti --user $(USER_ID):$(GROUP_ID) --rm -v $(PWD):/application -w /application node:alpine3.14 npm install

npm-watch: ## Compile assets during development
	docker run -ti --user $(USER_ID):$(GROUP_ID) --rm -v $(PWD):/application -w /application node:alpine3.14 npm run watch-poll

npm-dev: ## Build development assets
	docker run -ti --user $(USER_ID):$(GROUP_ID) --rm -v $(PWD):/application -w /application node:alpine3.14 npm run dev

init: build upd env composer-install npm-install npm-watch ## Do the initial setup and run the containers

run: build upd npm-watch ## Run the development environment

cache: ## Clear laravel cache
	docker exec --user $(USER_ID):$(GROUP_ID) -ti yourdomain-php-fpm php artisan cache:clear
	docker exec --user $(USER_ID):$(GROUP_ID) -ti yourdomain-php-fpm php artisan config:clear

cli-db: ## Connet to the terminal of yourdomain-mysql container
	docker exec --user $(USER_ID):$(GROUP_ID) -ti yourdomain-mysql bash

cli-php: ## Connet to the terminal of yourdomain-php-fpm container
	docker exec --user $(USER_ID):$(GROUP_ID) -ti yourdomain-php-fpm sh

cli-nginx: ## Connet to the terminal of yourdomain-nginx container
	docker exec --user $(USER_ID):$(GROUP_ID) -ti yourdomain-nginx bash

cli-composer: ## Connet to the terminal of composer:2 image based container
	docker run --rm -ti --user $(USER_ID):$(GROUP_ID) -v $(PWD):/app composer:2 bash

up: ## Run containers in the foreground
	docker-compose -p yourdomain --f $(DOCKER_COMPOSE_YML) up

down: ## Shut down containers and remove orphans
	docker-compose -p yourdomain --f $(DOCKER_COMPOSE_YML) down --remove-orphans

stop: ## Stop containers
	docker-compose -p yourdomain --f $(DOCKER_COMPOSE_YML) stop

destroy: down ## Shut down containers and do additional cleanup
	docker volume prune -f
	docker container prune -f
	docker image prune -f
	rm -rf vendor node_modules
	sudo rm -rf .docker/mysql/log .docker/nginx/log .docker/php-fpm/log