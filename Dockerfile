# Stage 1: Build assets dengan Node.js
FROM node:18 as build

WORKDIR /var/www

# Copy seluruh project (termasuk konfigurasi dan source)
COPY . .

# Install dependencies node
RUN npm install --unsafe-perm

# Update database browserslist
RUN npx browserslist@latest --update-db

# Build assets (ganti sesuai kebutuhan: prod, build, dll)
RUN npm run prod

# Pastikan folder public/css ada (hindari error COPY)
RUN mkdir -p /var/www/public/css

# Debug struktur build
RUN echo "Hasil build:" && ls -la public

# Stage 2: PHP-FPM
FROM php:8.1-fpm

# Install dependencies sistem
RUN apt-get update && apt-get install -y \
    unzip curl git zip libzip-dev libonig-dev libxml2-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring zip exif pcntl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy aplikasi PHP ke container
COPY . .

# Copy seluruh hasil build dari stage Node
COPY --from=build /var/www/public /var/www/public

# Install dependensi PHP (tanpa dev)
RUN composer install --no-dev --optimize-autoloader

# Permissions Laravel
RUN chmod -R 775 storage bootstrap/cache

# Cache config, route, dan view
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

EXPOSE 9000
CMD ["php-fpm"]
