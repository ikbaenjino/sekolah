# Gunakan image PHP resmi dengan Composer
FROM php:8.1

# Install ekstensi & alat pendukung Laravel
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    zip \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Set working directory
WORKDIR /app

# Copy semua file ke dalam container
COPY . .

# Install dependensi Laravel
RUN composer install --no-dev --optimize-autoloader

# Laravel port
EXPOSE 10000

# Perintah saat container dijalankan
CMD php artisan serve --host=0.0.0.0 --port=10000
