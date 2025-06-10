#!/bin/bash

set -e

echo "🔧 Menyiapkan Laravel..."

# Set permission folder storage dan cache
mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache
chmod -R 775 storage bootstrap/cache storage/framework
chown -R www-data:www-data storage bootstrap/cache

# Generate APP_KEY jika belum ada
if [ -z "$APP_KEY" ] || [[ "$APP_KEY" == "base64:"* && ${#APP_KEY} -le 32 ]]; then
  echo "⚠️  APP_KEY tidak valid, menghasilkan APP_KEY baru..."
  php artisan key:generate
fi

# Cache config
php artisan config:clear
php artisan config:cache

# Jalankan migrate database
echo "🔄 Menjalankan migrate..."
php artisan migrate --force

# Jalankan Laravel menggunakan internal webserver
echo "🚀 Laravel berjalan di http://0.0.0.0:8000"
exec php artisan serve --host=0.0.0.0 --port=8000
