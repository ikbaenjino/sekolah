FROM php:8.1

RUN apt-get update && apt-get install -y \
    unzip curl git zip libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev nodejs npm

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY . .

# ── FIX folder & permission ─────────────────────────────────────────
RUN mkdir -p storage/framework/{cache/data,sessions,views} storage/logs bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R 775 storage bootstrap/cache

# Install deps & build assets
RUN composer install --no-dev --optimize-autoloader \
 && npm install \
 && npm run prod

# (jangan config:cache di tahap build!)
EXPOSE 8000

CMD ["sh","-c","php artisan config:clear && php artisan serve --host=0.0.0.0 --port=8000"]
