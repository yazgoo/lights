load "#{File.dirname __FILE__}/homemodule.rb"
require 'open3'
class VideoPlayer < HomeModule
    def setup
        keys = {"fast-backward" => "\b[B", "backward" => "\b[D",
            "play" => " ", "pause" => " ", "stop" => "q", 
            "forward" => "\b[C", "fast-forward" => "\b[A"}
        omx = "/usr/bin/omxplayer"
        cmd = File.exists?(omx)?"#{omx} -o local -s":"mplayer" +
            " #{ENV['HOME']}/Videos/"
        thr = stdin = nil
        keys.each do |name, code|
            action name, {:icon => name}, Proc.new { |name|
                next if thr.nil? or not thr.alive?
                stdin.write code
                thr.join if name == "stop"
            }
        end
        action :start, {:parameters => {:name => {:type => :string}}},
            Proc.new { |name, parameters|
            call :stop
            stdin, stdout, stderr, thr = Open3.popen3(cmd + path)
            Thread.new { stdout.each_line {|line| puts line } }
        }
    end
end
