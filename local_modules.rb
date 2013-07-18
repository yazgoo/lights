# declare here what modules you want to instantiate localy
# launch these with module/modules.rb
RUN_GPIO_PATH="#{ENV['HOME']}/dev/wiringPi/gpio/run_"
VIDEOS_PATH="#{ENV['HOME']}/Videos"
ACTUATE_PATH="#{ENV['HOME']}/dev/lights/lights_actuate.rb"
VideoPlayer.new
Downloader.new VIDEOS_PATH
Heyu.new
Alarm.new :name=> "alarm", :aliases => {'actuate' => ACTUATE_PATH}
Alarm.new :name=> "alarm2", :aliases => {'actuate' => ACTUATE_PATH}
FileLister.new VIDEOS_PATH
System.new :name => "shutter",
    :commands => {:up => {:command => RUN_GPIO_PATH + "up", :icon => "arrow-up"},
        :down => {:command => RUN_GPIO_PATH + "down", :icon => "arrow-down"} }
System.new :name => "videoprojector", :commands => {:onoff => {:command =>
    "#{ENV['HOME']}/dev/irremote/write.py 10C8E11E", :icon => "off"} }
Tcp.new :name => "salon", :host => "192.168.0.177", :port => 42, :messages => {
    :on => {:message => "002", :icon => "circle"},
    :off => {:message => "102", :icon => "circle-blank"}}
