# --------------------------------------------
# STAGE 1: Build Frontend Assets (optional)
# --------------------------------------------
FROM node:18 AS node_modules

WORKDIR /var/www

# Copy only frontend files first
COPY package.json package-lock.json* webpack.mix.js ./
COPY resources/ resources/

# Install and build assets
RUN npm install && npm run prod

# --------------------------------------------
# STAGE 2: Laravel Production Image
# --------------------------------------------
FROM php:8.1-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev \
    curl \
    && docker-php-ext-install pdo_mysql zip gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy Laravel app
COPY . .

# Copy built frontend assets from previous stage
COPY --from=node_modules /var/www/public /var/www/public

# Set permissions for Laravel
RUN mkdir -p \
    storage/framework/{cache,data,sessions,views} \
    storage/logs bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Clear config cache to allow fresh APP_KEY on runtime
CMD php artisan config:clear && \
    php artisan serve --host=0.0.0.0 --port=8000

EXPOSE 8000
