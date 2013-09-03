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

Composer support is built in. Simpy drop your composer.json into the root of your repository the buildpack will automatically install the requirements and dependencies into the dyno. Because composer dependencies are saved in the dyno, when you scale up, all the dynos are ensured to be identical. Please be aware that if for example github is down when you push to heroku, that the composer install will fail and you will have a broken dyno and you should roll-back.

Hacking with shell scripts
--------------------------

This buildpack includes several hooks allowing you to add custom behavior when the dyno is compiled as well as when a dyno is spun up. By adding a .heroku/compile.sh script into the root of your repository (not the buildpack's repository), you can add additional hooks such as uploading static assets to your CDN, building the cache, etc. The .heroku/compile.sh file will be deleted before the dyno is saved and any other shell scripts in the .heroku directory will be executed when the dyno is spun up.

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
