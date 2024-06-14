# Use an official PHP runtime with Apache as the base image
FROM php:7.4-apache

# Set the server name to avoid the fully qualified domain name warning
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Set the working directory inside the container to the Apache document root
WORKDIR /var/www/html

# Copy the application's files into the container's web directory
COPY . /var/www/html

# Change ownership of the copied files to the Apache user and group
RUN chown -R www-data:www-data /var/www/html

# Change permissions for all directories and files to be accessible
RUN find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# Enable Apache mods
RUN a2enmod rewrite headers

# Configure Apache to allow .htaccess overrides and set up directory access
RUN echo '<Directory "/var/www/html">' > /etc/apache2/conf-available/custom.conf && \
    echo '    AllowOverride All' >> /etc/apache2/conf-available/custom.conf && \
    echo '    Options FollowSymLinks' >> /etc/apache2/conf-available/custom.conf && \
    echo '    Require all granted' >> /etc/apache2/conf-available/custom.conf && \
    echo '</Directory>' >> /etc/apache2/conf-available/custom.conf && \
    a2enconf custom

# Use the default production configuration if it exists
RUN if [ -f "/usr/local/etc/php/php.ini-production" ]; then \
        mv "/usr/local/etc/php/php.ini-production" "/usr/local/etc/php/php.ini"; \
    fi

# Ensure there is an index file to prevent directory listing issues
RUN touch /var/www/html/index.php
RUN echo "<?php phpinfo(); ?>" > /var/www/html/index.php

# Expose port 80 to allow communication to/from the server
EXPOSE 80

# Start Apache server in the foreground
CMD ["apache2-foreground"]
