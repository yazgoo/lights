#!/usr/bin/env ruby
load "#{File.dirname __FILE__}/homemodule.rb"
while true
    begin
        Dir[File.dirname(__FILE__) + "/*.rb"].each do |file|
            load file if not ["modules.rb", "homemodule.rb"].include? File.basename file
        end
        load File.dirname(__FILE__) + "/../local_modules.rb"
        while true
            sleep 10
        end
    rescue
        p $!
    end
end
