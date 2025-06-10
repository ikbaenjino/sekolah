# --------------------------------------------
# STAGE 1: Build Frontend Assets
# --------------------------------------------
FROM node:18 AS node_modules

WORKDIR /var/www

COPY package.json package-lock.json* webpack.mix.js ./
COPY resources/ resources/

RUN npm install && npm run prod

# --------------------------------------------
# STAGE 2: Laravel Production
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

# Set workdir
WORKDIR /var/www

# Copy Laravel project
COPY . .

# Copy built frontend
COPY --from=node_modules /var/www/public /var/www/public

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set permissions
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache storage/framework && \
    chown -R www-data:www-data storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Jalankan entrypoint script saat container dijalankan
CMD ["entrypoint.sh"]

EXPOSE 8000
