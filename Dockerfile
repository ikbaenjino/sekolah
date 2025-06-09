# ──────────────────────────────
# 1.  STAGE : build assets
# ──────────────────────────────
FROM node:18 AS build

WORKDIR /var/www

# Salin hanya berkas frontend terlebih dahulu (layer cache lebih efisien)
COPY package.json package-lock.json* ./
COPY webpack.mix.js vite.config.js* ./

# ← jika project Anda TIDAK memakai Mix/Vite,
#    hapus seluruh stage "build" sampai tanda === END BUILD ===

RUN npm install --unsafe-perm
RUN npm run prod   # atau npm run build / npm run production, sesuaikan

# Salin source yang dibutuhkan Mix (JS/SASS)
COPY resources ./resources
# === END BUILD ===================================================


# ──────────────────────────────
# 2.  STAGE : production image
# ──────────────────────────────
FROM php:8.1-cli AS app

# Dependensi sistem (Git, Zip, lib GD dkk)
RUN apt-get update && apt-get install -y \
        git unzip zip libzip-dev \
        libpng-dev libjpeg-dev libfreetype6-dev \
        libonig-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql zip gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# ── FIX  : pastikan direktori cache & storage ada + writable ──
RUN mkdir -p \
        bootstrap/cache \
        storage/framework/{cache,sessions,views} \
        storage/logs \
    && chmod -R 775 storage bootstrap/cache

# ── PHP dependency
RUN composer install --no-dev --optimize-autoloader

# ── Salin hasil build asset ke image produksi
COPY --from=build /var/www/public/js ./public/js
COPY --from=build /var/www/public/css ./public/css

# ── (optional) clear+cache config setiap start agar APP_KEY ter-load
CMD php artisan config:clear && \
    php artisan serve --host=0.0.0.0 --port=8000
EXPOSE 8000
