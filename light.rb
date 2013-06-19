#!/usr/bin/env ruby
require 'open3'
require 'rubygems'
require 'sinatra'
require 'socket'
require 'json'
HOME_PATH=ENV['HOME'] + "/"
OMXPLAYER="/usr/bin/omxplayer"
VIDEOS_PATH="#{HOME_PATH}Videos/"
DEV_PATH="#{HOME_PATH}dev/"
RUN_GPIO_PATH="#{DEV_PATH}wiringPi/gpio/run_"
IRREMOTE_PATH="#{DEV_PATH}irremote/write.py "
video_stdin = nil
video_thr = nil
get '/' do
    send_file File.join(settings.public_folder, 'index.htm')
end
get '/salon/:action' do |action|
    arduino = TCPSocket.new '192.168.0.177', 42
    arduino.puts "#{action == "on" ? 0:1}02"
    arduino.close
end
get '/store/:action' do |action|
    system "#{RUN_GPIO_PATH}#{action}"
end
get '/video/on-off' do
    system "#{IRREMOTE_PATH}10C8E11E"
end
get '/video/list' do
    files = []
    Dir.chdir VIDEOS_PATH do |dir|
        Dir["*.mp4"].sort {|a,b| File.ctime(a) <=> File.ctime(b) }.reverse.each do |video|
            files << {:name => video,
                :size => File.new(video).size }
        end
    end
    files.to_json
end
get '/video/control/:action' do |action|
    keys = {"fast-backward" => "\b[B",
        "backward" => "\b[D", "play" => " ", "pause" => " ",
        "stop" => "q", 
        "forward" => "\b[C", "fast-forward" => "\b[A"}
    video_stdin.write(keys[action]) if keys.has_key? action
    video_stdin = nil if action == "stop"
end
get '/media/play/:name' do |name|
    video_stdin.write("q") if not video_stdin.nil?
    video_stdin, stdout, stderr, video_thr = Open3.popen3("#{OMXPLAYER} -o local -s #{VIDEOS_PATH}#{name}")
    Thread.new do
        puts "reading stdout"
        stdout.each_line {|line| puts line }
    end
end
get '/disk/used' do
    line = ""
    `df /`.each_line { |l| line = l }
    line.split[4]
end
get '/media/remove/:name' do |name|
    File.delete("#{VIDEOS_PATH}#{name}")
end
