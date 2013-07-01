#!/usr/bin/env ruby
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
get '/' do
    send_file File.join(settings.public_folder, 'index.htm')
end
get '/salon/:action' do |action|
    arduino = TCPSocket.new '192.168.0.177', 42
    arduino.puts "#{action == "on" ? 0:1}02"
    arduino.close
end
get '/salon/lamp/dim/:value' do |value|
    `#{HEYU_PATH} dim E1 #{value}`
end
get '/salon/lamp/:action' do |action|
    `#{HEYU_PATH} #{action} E1`
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
            thread = download_threads[video]
            files << {:name => video,
                :size => (thread.nil? ? File.new(video).size : ((thread.instance_variable_get("@csize") * 100 / + thread.instance_variable_get("@size")).to_s + "%"))
             }
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
    video_stdin, stdout, stderr, video_thr = Open3.popen3("#{MEDIAPLAYER} \"#{VIDEOS_PATH}#{name}\"")
    Thread.new do
        puts "reading stdout"
        stdout.each_line {|line| puts line }
    end
end
post '/media/download/start/:name' do |name|
    url = URI params[:url]
    Thread.kill(download_threads[name]) if not download_threads[name].nil?
    download_threads[name] = Thread.new do
        redirected = true
        while redirected
            Net::HTTP.start(url.host) do |http|
                http.request_get(url.request_uri) do |resp|
                    if resp.header.code.to_i != 302
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
                    else
                        redirected = true
                        url = URI resp.header['Location']
                    end
                end
            end
        end
        download_threads[name] = nil
    end
end
get '/disk/used' do
    `df /`.split("\n").last.split[4]
end
get '/media/remove/:name' do |name|
    File.delete("#{VIDEOS_PATH}#{name}")
end
