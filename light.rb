#!/usr/bin/env ruby
# Author:: Olivier `yazgoo` Abdesselam
# Licence:: aGPLv2
# 
require 'rubygems'
require 'sinatra'
# return the main page
get '/' do
    send_file File.join(settings.public_folder, 'index.htm')
end
