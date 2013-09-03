Apache+PHP build pack
========================

This is a build pack bundling PHP and Apache for Heroku apps.

**Features:**
* PHP 5.5.3 (PHP-FPM)
* Apache HTTP Server 2.4.6
* Composer Support
* Opcache Enabled
* PECL Memcached
* GD support
* igbinary support
* mcrypt support (to support Laravel 4)
* PostgreSQL support

Configuration
-------------

The config files are bundled with the buildpack itself:

* conf/httpd.conf
* conf/php.ini

Configure Heroku to use this buildpack repo AND branch

    heroku config:set BUILDPACK_URL=git://github.com/winglian/heroku-buildpack-php.git#mpm-event-php55-fpm

This buildpack also supports custom Document Roots in your application. Simply add an environment variable. If your document root is public in the root of your repo, then run
    
    heroku config:set WWWROOT=/public

Composer
--------

Composer support is built in. Simpy drop your composer.json into the root of your repository the buildpack will automatically install the requirements and dependencies.

Pre-compiling binaries
----------------------

After building the binary below, update the OPT_BUILDPACK_URL variable in bin/compile to point to the url of the vulcan binary from Heroku

    vulcan build -v -s ./build -p /tmp/build -c "./vulcan.sh"

Hacking
-------

To change this buildpack, fork it on Github. Push up changes to your fork, then create a test app with --buildpack <your-github-url> and push to it.

Meta
----

Original buildpack by Pedro Belo. https://github.com/heroku/heroku-buildpack-php
