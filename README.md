A modular home automation console based on mqtt.
Here is an instance:

![screenshot 0](https://github.com/yazgoo/lights/raw/mqtt/screenshot/mqtt.png)


Install
=======

- $ sudo apt-get install mosquitto
- $ sudo apt-get install lighthttpd
- install [mod_websockets](https://github.com/nori0428/mod_websocket/wiki/for-Ubuntu-Users), ie:
    - $ apt-get install automake libtool openssl libssl-dev libev-dev libcunit1 libcunit1-dev libicu-dev bison flex
    - cd mod_websockets; ./bootstrap && ./configure && make clean check

Prerequisites
=============

- mosquitto-1.1.3
    - sudo apt-get install libssl-dev
- sudo apt-get install npm
- install nodejs (from source)
- sudo npm -g install ws
- sudo gem install mqtt timers cronedit
