#!/bin/bash

# Exit jika ada error
set -e

echo "🔧 Menyiapkan Laravel..."

# Set permission storage dan cache
mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache
chmod -R 775 storage bootstrap/cache
chmod -R 775 storage/framework
chown -R www-data:www-data storage bootstrap/cache

# Generate APP_KEY jika belum ada
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:" ]; then
  echo "⚠️  APP_KEY belum di-set. Menghasilkan APP_KEY..."
  php artisan key:generate
fi

# Bersihkan dan cache konfigurasi
php artisan config:clear
php artisan config:cache

# Jalankan migrasi
echo "🔄 Menjalankan migrate database..."
php artisan migrate --force

# Jalankan server Laravel
echo "🚀 Menjalankan Laravel di http://0.0.0.0:8000"
exec php artisan serve --host=0.0.0.0 --port=8000
