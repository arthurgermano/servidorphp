FROM ubuntu:14.04

# Updating repositories
RUN apt-get update
RUN apt-get -y upgrade

# Install Apache2 / PHP 5.5 & Co.
RUN apt-get -y install apache2 php5 libapache2-mod-php5 php5-dev php-pear php5-curl curl libaio1 libpcre3-dev gcc make re2c php5-odbc php5-xcache

# Install PostgreSQL Client / MYSQL Client / Several libraries PHP / MSSQL Client
RUN apt-get -y install php5-pgsql php5-mysql php5-apcu php5-gd php5-json php5-ldap php5-mcrypt php5-sqlite php5-xsl php5-redis php5-mssql git

# Adding MCRYPT configuration
RUN echo "extension=mcrypt.so" > /etc/php5/apache2/conf.d/20-mcrypt.ini
 
# Install the Oracle Instant Client
ADD oracle/oracle-instantclient11.2-basiclite_11.2.0.4.0-2_amd64.deb /tmp
ADD oracle/oracle-instantclient11.2-devel_11.2.0.4.0-2_amd64.deb /tmp
ADD oracle/oracle-instantclient11.2-sqlplus_11.2.0.4.0-2_amd64.deb /tmp
RUN dpkg -i /tmp/oracle-instantclient11.2-basiclite_11.2.0.4.0-2_amd64.deb
RUN dpkg -i /tmp/oracle-instantclient11.2-devel_11.2.0.4.0-2_amd64.deb
RUN dpkg -i /tmp/oracle-instantclient11.2-sqlplus_11.2.0.4.0-2_amd64.deb

# Set up the Oracle environment variables
ENV LD_LIBRARY_PATH /usr/lib/oracle/11.2/client64/lib/
ENV ORACLE_HOME /usr/lib/oracle/11.2/client64/lib/

# Adding PEAR Proxy
RUN pear config-set http_proxy http://localhost:8118

# Install the OCI8 PHP extension
RUN echo 'instantclient,/usr/lib/oracle/11.2/client64/lib' | pecl install -f oci8-2.0.8
RUN echo "extension=oci8.so" > /etc/php5/apache2/conf.d/30-oci8.ini

# Changing php.ini configuration to accept short tags
RUN sed -i 's/short_open_tag.*/short_open_tag = On/g' /etc/php5/apache2/php.ini

# Copying apache configuration files e environment variables
COPY apache2.conf /etc/apache2
COPY envvars /etc/apache2

# ADD PDO_OCI
ADD /pdo_oci /tmp/pdo_oci

# Creating symbolic links to help the script find itself!!!
RUN ln -s /usr/include/php5/ /usr/include/php
RUN mkdir /usr/lib/oracle/11.2/client64/lib/sdk && ln -s /usr/include/oracle/11.2/client64/ /usr/lib/oracle/11.2/client64/lib/sdk/include

# Configure PDO_OCI
RUN cd /tmp/pdo_oci/ && ./configure --with-pdo-oci=instantclient,/usr/lib/oracle/11.2/client64/lib,11.1

# Installing PDO_OCI
RUN cd /tmp/pdo_oci && make && make install && cd /

# Enabling PDO_OCI into PHP5
RUN echo "extension=pdo_oci.so" > /etc/php5/mods-available/pdo_oci.ini
RUN echo "extension=pdo_oci.so" > /etc/php5/apache2/conf.d/30-pdo_oci.ini

RUN cd /tmp && git clone git://github.com/phalcon/cphalcon.git && cd cphalcon && git checkout tags/phalcon-v2.0.13 && cd build && ./install && cd /

RUN echo "extension=phalcon.so" > /etc/php5/mods-available/phalcon.ini
RUN echo "extension=phalcon.so" > /etc/php5/apache2/conf.d/30-phalcon.ini


# Enable Apache2 modules
RUN a2enmod rewrite

# Set up the Apache2 environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Exposing ports to accept connections
EXPOSE 80
EXPOSE 5432
EXPOSE 3306
EXPOSE 1521

# Run Apache2 in Foreground
CMD /usr/sbin/apache2 -D FOREGROUND

MAINTAINER Arthur Jose Germano <email@email.com>
