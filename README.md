A modular home automation console based on mqtt.
Here is an instance:

![screenshot 0](https://github.com/yazgoo/lights/raw/mqtt/screenshot/mqtt.png)


Install on raspbian
===================

- $ sudo apt-get install mosquitto
- get latest httpd from source:
- install [mod_websockets](https://github.com/nori0428/mod_websocket/wiki/for-Ubuntu-Users), ie:
    - clone repository
    - $ apt-get install automake libtool openssl libssl-dev libev-dev libcunit1 libcunit1-dev libicu-dev bison flex
    - cd mod_websockets; ./bootstrap && ./configure && make clean check
    - ./configure --lighttpd=/path/to/lighttpd_source
    - make install
- sudo apt-get install libpcre3-dev libbz2-dev
- build lighttpd

Install on Archlinux
====================

- get lighttpd sources
- install mod_websockets, i.e:
    - # pacman -S automake openssl libev icu bison flex libtool
    - $ clone repository
    - $ cd mod_websokets; ./bootstrap && ./configure --without-test && make
    - $ ./configure --lighttpd=/path/to/lighttpd_source
    - $ make install
- build lighttpd:
    - cd /path/to/lighttpd_source
    - ./autogen.sh
    - ./configure --with-websocket=ALL
    - make

Prerequisites
=============

- mosquitto-1.1.3
    - sudo apt-get install libssl-dev
- sudo apt-get install npm
- install nodejs (from source)
- sudo npm -g install ws
- sudo gem install mqtt timers cronedit
