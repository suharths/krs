FROM ubuntu:jammy
MAINTAINER suhart.hs@gmail.com

RUN apt update
RUN apt -y upgrade
RUN apt -y install apt-utils
RUN DEBIAN_FRONTEND=noninteractive TZ=Asia/Jakarta apt-get -y install tzdata
# Install Apache2 / PHP 7.
RUN apt install -y apache2 php  libapache2-mod-php php-cli php-common php-mbstring php-gd php-intl php-xml  php-zip php-pear php-curl curl alien libaio1 php-dev
# Copy semua Install the Oracle Instant Client
ADD oracle/oracle-instantclient-basic_21.6.0.0.0-2_amd64.deb /tmp
ADD oracle/oracle-instantclient-devel_21.6.0.0.0-2_amd64.deb /tmp
ADD oracle/oracle-instantclient-devel_21.6.0.0.0-2_amd64.deb /tmp
RUN dpkg -i /tmp/oracle-instantclient-basic_21.6.0.0.0-2_amd64.deb
RUN dpkg  -i /tmp/oracle-instantclient-devel_21.6.0.0.0-2_amd64.deb
RUN dpkg  -i /tmp/oracle-instantclient-devel_21.6.0.0.0-2_amd64.deb

# Hapus rpm
RUN rm -rf /tmp/oracle-instantclient-*.deb

# Set up the Oracle environment variables
ENV LD_LIBRARY_PATH /usr/lib/oracle/21/client64/lib/ 
ENV ORACLE_HOME /usr/lib/oracle/21/client64/lib/

# Install the OCI8 PHP extension
RUN export PHP_DTRACE=yes
RUN echo 'instantclient,/usr/lib/oracle/21/client64/lib/' | pecl install -f oci8-2.2.0
RUN echo "extension=oci8.so" > /etc/php7/apache2/conf.d/30-oci8.ini

# Enable Apache2 modules
RUN a2enmod rewrite

# Set up the Apache2 environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

# Run Apache2 in Foreground
CMD /usr/sbin/apache2 -D FOREGROUND
