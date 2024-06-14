# Use an official PHP runtime as a parent image with Apache
FROM php:7.4-apache

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the current directory contents into the container at /var/www/html
COPY . /var/www/html

# Expose port 80 to allow communication to/from the server
EXPOSE 80

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Further customize the configuration, if necessary
# RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/' $PHP_INI_DIR/php.ini

# Grant permissions for the public directory (adjust as necessary)
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Start Apache server in the foreground
CMD ["apache2-foreground"]
