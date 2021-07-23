FROM php:8.0.0-fpm
WORKDIR "/application"

## Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

### php extensions
RUN docker-php-ext-install pdo_mysql
