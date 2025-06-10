# --------------------------------------------
# STAGE 1: Build Frontend Assets (Laravel Mix)
# --------------------------------------------
FROM node:18 AS node_modules

WORKDIR /var/www

COPY package.json package-lock.json* webpack.mix.js ./
COPY resources/ resources/

RUN npm install && npm run prod

# --------------------------------------------
# STAGE 2: Laravel Production with PHP 8.1 & PostgreSQL
# --------------------------------------------
FROM php:8.1-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git unzip zip libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev \
    libpq-dev \
    curl \
    && docker-php-ext-install pdo_mysql pdo_pgsql zip gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set work directory
WORKDIR /var/www

# Copy all project files
COPY . .

# Copy built frontend assets
COPY --from=node_modules /var/www/public /var/www/public

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set permissions for Laravel
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache && \
    chmod -R 775 storage bootstrap/cache storage/framework && \
    chown -R www-data:www-data storage bootstrap/cache

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Run Laravel using custom entrypoint
CMD ["entrypoint.sh"]

EXPOSE 8000
