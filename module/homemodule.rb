require 'rubygems'
require 'json'
require 'mqtt'
class MqttManaged 
    Actuator = '/home/actuators'
    Host = 'localhost'
    @@modules = []
    attr_reader :name
    def initialize
        self.class.mqtt_run if @@modules.empty?
        @name = self.class.name
        @@modules << self
    end
    def mqtt_publish_values
        topic = "#{Actuator}/#{@name}/values"
        @@client.publish topic, @actions.to_json
        # @@client.instance_variable_get(:@socket).flush
        # I know, this is hacky, but otherwise publish
        # show up grouped in the browser
        sleep 0.05
    end
    def self.mqtt_run
        @@client = MQTT::Client.connect(Host)
        Thread.new do
            begin
                MQTT::Client.connect(Host) do |c|
                    c.get(Actuator + "/#") do |topic,message|
                        puts topic, message
                        if topic == Actuator and message == 'list'
                            @@modules.each do |mod|
                                mod.mqtt_publish_values
                            end
                        else
                            @@modules.each do |mod|
                                if topic == "#{Actuator}/#{mod.name}"
                                    mod.call *message.split
                                end
                            end
                        end
                    end
                end
            rescue err
                p err
            end
        end
    end
end
class HomeModule < MqttManaged
    def action name, parameters, _proc
        @procs[name.to_s] = _proc
        @actions[name.to_s] = parameters
    end
    def initialize
        super
        @actions = {}
        @procs = {}
        setup
    end
    def call name, *parameters
        name = name.to_s
        return if @actions[name].nil?
        @procs[name].call(name, parameters[0])
    end
end
