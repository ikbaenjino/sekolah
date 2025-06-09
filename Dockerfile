FROM php:8.1-cli

# Install dependencies
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

# Copy application files
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Install JS dependencies and build assets
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install && \
    npm run build

# Fix cache directory permissions
RUN mkdir -p bootstrap/cache \
    && chown -R www-data:www-data bootstrap/cache \
    && chmod -R 775 bootstrap/cache

# Set owner and permissions
RUN chown -R www-data:www-data /var/www

# Use PHP built-in server
EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
