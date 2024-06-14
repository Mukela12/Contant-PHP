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
RUN echo "<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// configure
$from = 'Demo contact form <demo@domain.com>';
$sendTo = 'Test contact form <Mukelathegreat@gmail.com>'; // Add Your Email
$subject = 'New message from contact form';
$fields = array('name' => 'Name', 'subject' => 'Subject', 'email' => 'Email', 'message' => 'Message'); // array variable name => Text to appear in the email
$okMessage = 'Contact form successfully submitted. Thank you, I will get back to you soon!';
$errorMessage = 'There was an error while submitting the form. Please try again later';

try
{
    $emailText = "You have new message from contact form\n=============================\n";

    // Validate and sanitize each field
    foreach ($_POST as $key => $value) {
        if (isset($fields[$key])) {
            $value = strip_tags(trim($value)); // Basic sanitation
            $emailText .= "$fields[$key]: $value\n";
        }
    }

    $headers = array(
        'Content-Type: text/plain; charset="UTF-8";',
        'From: ' . $from,
        'Reply-To: ' . $from,
        'Return-Path: ' . $from,
    );
    
    // Send the email
    if (mail($sendTo, $subject, $emailText, implode("\n", $headers))) {
        $responseArray = array('type' => 'success', 'message' => $okMessage);
    } else {
        throw new Exception('Failed to send email.');
    }
}
catch (Exception $e)
{
    $responseArray = array('type' => 'danger', 'message' => $errorMessage . ' ' . $e->getMessage());
}

if (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
    $encoded = json_encode($responseArray);

    header('Content-Type: application/json');

    echo $encoded;
}
else {
    echo $responseArray['message'];
}

?>
" > /var/www/html/index.php

# Expose port 80 to allow communication to/from the server
EXPOSE 80

# Start Apache server in the foreground
CMD ["apache2-foreground"]
