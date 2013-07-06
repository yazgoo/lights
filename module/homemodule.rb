require 'rubygems'
require 'json'
require 'mqtt'
class MqttManaged 
    Actuator = '/home/actuators'
    Host = 'localhost'
    @@modules = []
    def initialize
        self.class.mqtt_run if @@modules.empty?
        @@modules << self
    end
    def mqtt_publish_values
        topic = "#{Actuator}/blah/values"
        puts topic
        puts "lol"
        p @actions
        puts "publish #{topic} #{@actions.to_json}"
        @@client.publish topic, @actions.to_json
        
    end
    def self.mqtt_run
        @@client = MQTT::Client.connect(Host)
        Thread.new do
            MQTT::Client.connect(Host) do |c|
                c.get(Actuator) do |topic,message|
                    puts topic, message
                    if topic == Actuator and message == 'list'
                        @@modules.each do |mod|
                            mod.mqtt_publish_values
                        end
                    else
                        puts "other " + topic + " " + message
                    end
                end
            end
        end
    end
end
class HomeModule < MqttManaged
    def action name, parameters, _proc
        @actions[name.to_s] = {
            :parameters => parameters,
            :proc => _proc
        }
    end
    def initialize
        super
        @actions = {}
        setup
    end
    def call name, *parameters
        name = name.to_s
        return if @actions[name].nil?
        @actions[name][:proc].call(name, parameters[0])
    end
end
