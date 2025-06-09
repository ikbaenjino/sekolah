// Versi minimal jika tidak menggunakan CSS
const mix = require('laravel-mix');
mix.js('resources/js/app.js', 'public/js');

// Jika menggunakan CSS/Sass
// .sass('resources/sass/app.scss', 'public/css')
// atau
// .postCss('resources/css/app.css', 'public/css')
# Jika resources/js/app.js tidak ada
mkdir -p resources/js && touch resources/js/app.js

# Jika ingin menggunakan Sass
mkdir -p resources/sass && touch resources/sass/app.scss
npm install
composer install
