FROM php:8.0-fpm-alpine

RUN apk add --update --no-cache --virtual .build-deps build-base git autoconf mysql-client

# Add user for nette application
RUN addgroup w
RUN adduser www --disabled-password && adduser www w

# Clear cache
RUN rm -rf /var/cache/apk/*

# Install extensions
RUN docker-php-ext-install pdo_mysql

RUN docker-php-source delete

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY ./php-local.ini /usr/local/etc/php/conf.d/local.ini
COPY ./php-fpm-www.conf /usr/local/etc/php-fpm.d/www.conf

RUN mkdir -p /home/php/api/vendor && chown -R www:www /home/php/api

COPY --chown=www:www ./ /var/www/api

# Set working directory
WORKDIR /var/www/api

USER www

RUN composer install --no-ansi --no-dev --no-interaction --no-plugins --no-progress --no-scripts --optimize-autoloader

USER root

RUN apk del .build-deps

USER www

# Expose port 9000 and start php-fpm server
EXPOSE 9000

CMD ["php-fpm"]
