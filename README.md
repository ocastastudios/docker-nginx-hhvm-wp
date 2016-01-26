# docker-nginx-hhvm-for-wp
A docker image for running wordpress using hhvm, nginx and supervisor. 

This image includes a pre-requisites for video and image manipulation plugins, wp-cli and has Composer installed for plugin management

For a templated project that uses this as a basis for creating a Bedrock Wordpress project take a look at https://github.com/ocastastudios/dockerised-bedrock

The image uses ssmtp for implementing sendmail. In order to configure this you can set the following environment variables when running the image and they will be copied to /etc/ssmtp/ssmtp.conf:

  - SMTP_HOSTNAME
  - SMTP_ADMIN_EMAIL
  - SMTP_SERVER
  - SMTP_USERNAME
  - SMTP_PASSWORD
  - SMTP_USE_TLS
  - SMTP_STARTTLS

Cron is configured to fire a http://127.0.0.1/wp/wp-cron.php request every 10 minutes so Wordpress Cron should be disabled

HHVM and Nginx logs are redirected to /dev/stdout so that they appear in the `docker logs` output

A project specific .env file should be mounted to _/var/www/public\_html/.env_

The image also contains aaemnnosttv/wp-cli-dotenv-command so you can generate a set of WP salts by running the command: 
   
   wp --allow-root dotenv salts generate --file=.env
