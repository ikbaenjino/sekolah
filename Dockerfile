# Stage 1: Build assets
FROM node:18 as frontend

WORKDIR /var/www

COPY package*.json webpack.mix.js ./
COPY resources/ resources/

RUN npm install && npm run prod

# Stage 2: PHP + Laravel
FROM php:8.1-cli

RUN apt-get update && apt-get install -y \
    git unzip zip libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev \
    curl libpq-dev \
    && docker-php-ext-install pdo_pgsql zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

COPY --from=frontend /var/www/public /var/www/public

RUN mkdir -p \
    storage/framework/{cache,sessions,views} \
    storage/logs bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

RUN composer install --no-dev --optimize-autoloader

CMD php artisan config:clear && php artisan serve --host=0.0.0.0 --port=8000

EXPOSE 8000
