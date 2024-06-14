# Use an official PHP runtime with Apache as the base image
FROM php:7.4-apache

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

# Use the default production configuration for PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Optionally adjust PHP settings for file uploads, memory limits, etc.
# RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/' $PHP_INI_DIR/php.ini
# RUN sed -i 's/post_max_size = 8M/post_max_size = 20M/' $PHP_INI_DIR/php.ini

# Expose port 80 to allow communication to/from the server
EXPOSE 80

<<<<<<< HEAD
# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Further customize the configuration, if necessary
# RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/' $PHP_INI_DIR/php.ini

# Grant permissions for the public directory (adjust as necessary)
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

=======
>>>>>>> 8dcfc021e2661a9f238c3346a13c17e5629f8010
# Start Apache server in the foreground
CMD ["apache2-foreground"]
