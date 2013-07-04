#!/usr/bin/env ruby
# This web service allows to control automation at home
# Author:: Olivier `yazgoo` Abdesselam
# Licence:: aGPLv2
# 
require 'open3'
require 'rubygems'
require 'sinatra'
require 'socket'
require 'json'
require 'uri'
require 'net/http'
HOME_PATH=ENV['HOME'] + "/"
OMXPLAYER="/usr/bin/omxplayer"
MEDIAPLAYER=File.exists?(OMXPLAYER)?"#{OMXPLAYER} -o local -s":"mplayer"
VIDEOS_PATH="#{HOME_PATH}Videos/"
DEV_PATH="#{HOME_PATH}dev/"
RUN_GPIO_PATH="#{DEV_PATH}wiringPi/gpio/run_"
IRREMOTE_PATH="#{DEV_PATH}irremote/write.py "
HEYU_PATH="/home/pi/dev/heyu-2.11-rc1/heyu -c #{ENV['HOME']}/.heyu/x10config "
video_stdin = nil
video_thr = nil
download_threads = {}
# return the main page
get '/' do
    send_file File.join(settings.public_folder, 'index.htm')
end
# switch off/on the salon on the salon light
# == Parameters:
# +action+:: "on" or "off"
get '/salon/:action' do |action|
    arduino = TCPSocket.new '192.168.0.177', 42
    arduino.puts "#{action == "on" ? 0:1}02"
    arduino.close
end
# dim the salon lamp on off
# == Parameters:
# +value+:: the dim value between 1 and 22
get '/salon/lamp/dim/:value' do |value|
    `#{HEYU_PATH} dim E1 #{value}`
end
# set on off the salon lamp
# == Parameters:
# +action+:: "on" or "off"
get '/salon/lamp/:action' do |action|
    `#{HEYU_PATH} #{action} E1`
end
# put down or up rolling shutters
# == Parameters:
# +action+:: "up" or "down"
get '/store/:action' do |action|
    system "#{RUN_GPIO_PATH}#{action}"
end
# switch on off the videoprojector
get '/video/on-off' do
    system "#{IRREMOTE_PATH}10C8E11E"
end
# list the mp4 videos as JSON
# Each item in the list contains to attributes
# -name: the file name
# -size: the size in bytes, 
#       or if it is being downloaded by the app, the percentage
get '/video/list' do
    files = []
    Dir.chdir VIDEOS_PATH do |dir|
        Dir["*.mp4"].sort {|a,b| File.ctime(a) <=> File.ctime(b) }.reverse.each do |video|
            thread = download_threads[video]
            files << {:name => video,
                :size => (thread.nil? ? File.new(video).size : ((thread.instance_variable_get("@csize") * 100 / + thread.instance_variable_get("@size")).to_s + "%"))
             }
        end
    end
    files.to_json
end
# control the current video being played
# == Parameters:
# +action+:: "fast-backward", "backward", "play", "pause", "stop", "forward", "fast-forward"
get '/video/control/:action' do |action|
    keys = {"fast-backward" => "\b[B",
        "backward" => "\b[D", "play" => " ", "pause" => " ",
        "stop" => "q", 
        "forward" => "\b[C", "fast-forward" => "\b[A"}
    video_stdin.write(keys[action]) if keys.has_key? action
    video_stdin = nil if action == "stop"
end
# play a video
# == Parameters:
# +name+:: the name of the video to play
get '/media/play/:name' do |name|
    video_stdin.write("q") if not video_stdin.nil?
    video_stdin, stdout, stderr, video_thr = Open3.popen3("#{MEDIAPLAYER} \"#{VIDEOS_PATH}#{name}\"")
    Thread.new do
        puts "reading stdout"
        stdout.each_line {|line| puts line }
    end
end
# start playing a video
# == Parameters:
# +url+:: url the url to play
get '/media/download/start' do
    url = URI params[:url]
    redirected = true
    while redirected
        Net::HTTP.start(url.host) do |http|
            http.request_get(url.request_uri) do |resp|
                if resp.header.code.to_i != 302
                    name = resp.header['Content-Disposition'].scan(/filename="([^"]+)"/)[0][0]
                    Thread.kill(download_threads[name]) if not download_threads[name].nil?
                    download_threads[name] = Thread.new do
                        redirected = false
                        Thread.current.instance_variable_set("@csize", 0)
                        Thread.current.instance_variable_set("@size", resp.header.content_length)
                        begin
                            f = open "#{VIDEOS_PATH}#{name}", "w"
                            resp.read_body do |segment|
                                Thread.current.instance_variable_set("@csize", Thread.current.instance_variable_get("@csize") + segment.size)
                                f.write segment
                            end
                        ensure
                            f.close
                        end
                        download_threads[name] = nil
                    end
                else
                    url = URI resp.header['Location']
                end
            end
        end
    end
end
# returns the percentage of use of /
get '/disk/used' do
    `df /`.split("\n").last.split[4]
end
# delete a file in media directory
# == Parameters:
# +name+:: name of the file
get '/media/remove/:name' do |name|
    File.delete("#{VIDEOS_PATH}#{name}")
end
# returns the wake-up timer with to parameters
# (hour, and minute)
get '/timer' do
    minute, hour = `crontab -l`.split("\n").collect { |line| line if line.match('# timer$') }.delete_if {|x| x == nil}.first.split
    {:hour => hour, :minute => minute}.to_json
end
# set the wake up timer
# == Parameters:
# +hour+::
# +minute+::
get '/timer/:hour/:minute' do |hour, minute|
    `crontab -l | sed 's/^[^\\s]\\+\\s[^\\s]\\+\\s\\(.\\s.\\s.\\s.*# timer\\)$/#{minute} #{hour} \\1/' | crontab -`
end
