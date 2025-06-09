FROM php:8.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip curl git zip \
    libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev nodejs npm

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy project files
COPY . .

# ✅ FIX: Buat folder cache dan ubah permission & kepemilikan
RUN mkdir -p bootstrap/cache \
    && chown -R www-data:www-data bootstrap/cache \
    && chmod -R 775 bootstrap/cache

# Install dependencies & build assets
RUN composer install --no-dev --optimize-autoloader \
    && npm install \
    && npm run prod \
    && php artisan config:cache \
    && php artisan migrate --force || true \
    && php artisan storage:link || true

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
