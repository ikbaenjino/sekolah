# -----------------------------
# STAGE 1 : Build frontend (optional)
# -----------------------------
FROM node:18 AS node_modules
WORKDIR /var/www

# Jika belum ada package.json, lewati blok ini
COPY package.json package-lock.json* webpack.mix.js ./
COPY resources/ resources/
RUN npm install --no-audit --silent && npm run prod

# -----------------------------
# STAGE 2 : Laravel runtime
# -----------------------------
FROM php:8.1-cli

# ======  PHP & system deps  ======
RUN apt-get update && apt-get install -y \
        git unzip zip  \
        libzip-dev libpq-dev \
        libpng-dev libjpeg-dev libfreetype6-dev \
        libonig-dev libxml2-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_pgsql pgsql zip gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ======  Composer  ======
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ======  App files  ======
WORKDIR /var/www
COPY . .
# Assets hasil build
COPY --from=node_modules /var/www/public /var/www/public

# ======  Permissions  ======
RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# ======  PHP deps  ======
RUN composer install --no-dev --optimize-autoloader --no-interaction

# ======  Entrypoint  ======
EXPOSE 10000
CMD php artisan config:clear \
 && php artisan migrate --force || true \
 && php artisan serve --host=0.0.0.0 --port=10000
