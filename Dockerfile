# Stage 1: Build assets dengan Node.js
FROM node:18 as build

WORKDIR /var/www

# Install node_modules terlebih dahulu untuk caching
COPY package.json package-lock.json ./
RUN npm install --unsafe-perm

# Update browserslist database
RUN npx browserslist@latest --update-db

# Copy semua resources
COPY resources resources/
COPY webpack.mix.js ./

# Verifikasi file ada sebelum build
RUN ls -la resources/sass/ && \
    npm run prod

# Stage 2: Aplikasi PHP
FROM php:8.1-fpm

# Install dependencies system
RUN apt-get update && apt-get install -y \
    unzip curl git zip libzip-dev libonig-dev libxml2-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring zip exif pcntl

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy aplikasi (gunakan .dockerignore untuk exclude file tidak perlu)
COPY . .

# Copy hasil build assets dari stage pertama
COPY --from=build /var/www/public/js /var/www/public/js
COPY --from=build /var/www/public/css /var/www/public/css

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Setup permissions
RUN chmod -R 775 storage bootstrap/cache

# Environment setup untuk production
RUN php artisan config:cache && \
    php artisan view:cache && \
    php artisan route:cache

EXPOSE 9000
CMD ["php-fpm"]
