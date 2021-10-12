FROM php:8.0-fpm-alpine

RUN apk add --update --no-cache --virtual .build-deps build-base git autoconf

# Install dependencies
#RUN apk add --update --no-cache \
#    imagemagick \
#    imagemagick-dev \
#    libressl-dev \
#    libzip-dev \
#    libpng-dev \
#    libjpeg-turbo-dev \
#    freetype-dev \
#    libpng-dev \
#    libwebp-dev \
#    shadow \
#    mariadb-client \
#    libintl \
#    zip \
#    jpegoptim \
#    optipng \
#    pngquant \
#    gifsicle \
#    unzip \
#    curl \
#    ffmpeg

# Add user for laravel application
RUN addgroup w
RUN adduser www --disabled-password && adduser www w
#RUN addgroup w
#RUN adduser -s /bin/bash -g www w

# Clear cache
RUN rm -rf /var/cache/apk/*

# Install extensions
#RUN docker-php-ext-configure gd --with-freetype --with-jpeg
#RUN docker-php-ext-install -j$(nproc) gd
#RUN docker-php-ext-install zip
#RUN pecl install xdebug
#RUN docker-php-ext-enable xdebug
# RUN pecl install imagick
# RUN docker-php-ext-enable imagick
#RUN pecl install mongodb
#RUN docker-php-ext-enable mongodb
RUN docker-php-ext-install pdo_mysql
#RUN docker-php-ext-install exif
#RUN docker-php-ext-install pcntl
#RUN docker-php-ext-install bcmath
RUN docker-php-source delete

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./php-local.ini /usr/local/etc/php/conf.d/local.ini
COPY ./php-fpm-www.conf /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /home/php/api/vendor && chown -R www:www /home/php/api

COPY --chown=www:www ./ /home/php/api

# Set working directory
WORKDIR /home/php/api

USER www

RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-ansi --no-interaction --no-plugins --no-progress --no-scripts --no-suggest --optimize-autoloader
#RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-ansi --no-dev --no-interaction --no-plugins --no-progress --no-scripts --no-suggest --optimize-autoloader

USER root

RUN apk del .build-deps

USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
