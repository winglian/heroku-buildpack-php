Apache+PHP build pack
========================

This is a build pack bundling PHP and Apache for Heroku apps.

**Features:**
* PHP 5.5.11 (PHP-FPM)
* Apache HTTP Server 2.4.9
* Composer Support
* Opcache Enabled
* PECL Memcached
* GD support
* igbinary support
* mcrypt support (to support Laravel 4)
* PostgreSQL support
* MongoDB support

Configuration
-------------

The config files are bundled with the buildpack itself:

* conf/httpd.conf
* conf/php.ini

Configure Heroku to use this buildpack repo AND branch

    $ heroku config:set BUILDPACK_URL=git://github.com/winglian/heroku-buildpack-php.git#mpm-event-php55-fpm

This buildpack also supports custom Document Roots in your application. Simply add an environment variable. If your document root is public in the root of your repo, then run
    
    $ heroku config:set WWWROOT=/public

Composer
--------

Composer support is built in. Simpy drop your composer.json into the root of your repository the buildpack will automatically install the requirements and dependencies into the dyno. Because composer dependencies are saved in the dyno, when you scale up, all the dynos are ensured to be identical. Please be aware that if for example github is down when you push to heroku, that the composer install will fail and you will have a broken dyno and you should roll-back.

Composer Private Repository Support
-----------------------------------

This buildpack now supports private repositories. You should create a new ssh keypair, which you should tar and then AES encrypt and make publicly available. You can either store the encrypted bundle on S3 or a publicly available git repo that allows public access the raw contents. See <http://getcomposer.org/doc/05-repositories.md#using-private-repositories> for information on how to setup private repositories in your composer.json.

    $ export SSH_BUNDLE_PASSWORD="Y0urSup3rS3cretP@ssw0rd"
    $ heroku config:set SSH_BUNDLE_PASSWORD={$SSH_BUNDLE_PASSWORD}
    $ cd /tmp
    $ ssh-keygen -t rsa -b 2048
    Generating public/private rsa key pair.
    Enter file in which to save the key (~/.ssh/id_rsa): /tmp/.ssh/id_rsa
    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 
    Your identification has been saved in /tmp/.ssh/id_rsa.
    Your public key has been saved in /tmp/.ssh/id_rsa.pub.
    $ cat << 'EOF' > /tmp/.ssh/config
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
    EOF
    $ tar -czv .ssh | openssl enc -out ssh_bundle_enc -e -k $SSH_BUNDLE_PASSWORD -aes-128-cbc

You will then need to upload ssh_bundle_enc to either S3 or save to a public git repo and allow authentication with /tmp/.ssh/id_rsa.pub to your private repository

    $ cd -
    $ heroku config:set SSH_BUNDLE_URL="http://s3.amazonaws.com/bucket/{path to folder containing ssh_bundle_enc}/ssh_bundle_enc"
    $ heroku labs:enable user-env-compile


Hacking with shell scripts
--------------------------

This buildpack includes several hooks allowing you to add custom behavior when the dyno is compiled as well as when a dyno is spun up. By adding a .heroku/compile.sh script into the root of your repository (not the buildpack's repository), you can add additional hooks such as uploading static assets to your CDN, building the cache, etc. The .heroku/compile.sh file will be deleted before the dyno is saved and any other shell scripts in the .heroku directory will be executed when the dyno is spun up.

Pre-compiling binaries
----------------------

After building the binary below, update the OPT_BUILDPACK_URL variable in bin/compile to point to the url of the vulcan binary from Heroku

    $ vulcan build -v -s ./build -p /tmp/build -c "./vulcan.sh"

Hacking
-------

To change this buildpack, fork it on Github. Push up changes to your fork, then create a test app with --buildpack <your-github-url> and push to it.

Meta
----

Original buildpack by Pedro Belo. https://github.com/heroku/heroku-buildpack-php
