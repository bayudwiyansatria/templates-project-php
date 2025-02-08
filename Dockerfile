#-----------------------------------------------------------------------------------------------------------------------
# Docker Base
#-----------------------------------------------------------------------------------------------------------------------
FROM php:8.2-fpm AS base
WORKDIR /var/www/html
LABEL maintainer="bayudwiyansatria@gmail.com"

RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    libonig-dev \
    zlib1g-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install pdo pdo_mysql mysqli mbstring zip opcache bcmath intl

#-----------------------------------------------------------------------------------------------------------------------
# Docker Build
#-----------------------------------------------------------------------------------------------------------------------
FROM composer:2.8.5 AS build
WORKDIR /build

COPY build .

RUN composer run clear
RUN php artisan optimize
RUN php artisan key:generate
RUN composer install

#-----------------------------------------------------------------------------------------------------------------------
# Docker Release
#-----------------------------------------------------------------------------------------------------------------------
FROM base AS release

COPY --from=build /build .

RUN chmod -R 775 storage bootstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
