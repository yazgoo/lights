#!/usr/bin/env ruby
require 'rubygems'
require 'mqtt'
client = MQTT::Client.connect '127.0.0.1'
client.publish "/home/actuators/#{ARGV[0]}", ARGV[1]
