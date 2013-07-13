# declare here what modules you want to instantiate localy
# launch these with module/modules.rb
VideoPlayer.new
Heyu.new
Alarm.new "alarm"
FileLister.new "#{ENV['HOME']}/Videos"
