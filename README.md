Apache+PHP build pack
========================

This is a build pack bundling PHP and Apache for Heroku apps.

Configuration
-------------

The config files are bundled with the buildpack itself:

* conf/httpd.conf
* conf/php.ini

Configure Heroku to use this buildpack repo AND branch

    heroku config:set BUILDPACK_URL=git://github.com/winglian/heroku-buildpack-php.git#mpm-event-php-fpm

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
