load "#{File.dirname __FILE__}/videoplayer.rb"
load "#{File.dirname __FILE__}/heyu.rb"
VideoPlayer.new
Heyu.new
while true
    sleep 10
end
