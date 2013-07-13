require 'rubygems'
require 'json'
require 'mqtt'
require 'timers'
class Proc
    def to_json *a
        self.yield.to_json *a
    end
end
class MqttManaged 
    Actuator = '/home/actuators'
    Sensor = '/home/sensors'
    Host = 'localhost'
    @@modules = []
    attr_reader :name
    def initialize params
        self.class.mqtt_run if @@modules.empty?
        @name = self.class.name
        @@modules << self
    end
    def mqtt_publish_values
        return if @actions.empty?
        topic = "#{Actuator}/#{@name}/values"
        @@client.publish topic, @actions.to_json
        # @@client.instance_variable_get(:@socket).flush
        # I know, this is hacky, but otherwise publish
        # show up grouped in the browser
        sleep 0.05
    end
    def send_sense name, values
        @@client.publish "#{Sensor}/#{@name}/#{name}",
        values.to_json
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
            rescue
                p $!
            end
        end
    end
end
class HomeModule < MqttManaged
    def action name, parameters, _proc
        @procs[name.to_s] = _proc
        @actions[name.to_s] = parameters
    end
    def sense name, parameters
        timers = Timers.new
        timers.every parameters[:period][:seconds] do
            send_sense name, yield
        end
        Thread.new { loop { timers.wait } }
    end 
    def initialize params = nil
        super params
        @actions = {}
        @params = params
        @procs = {}
        setup
    end
    def call name, *parameters
        name = name.to_s
        return if @actions[name].nil?
        params = parameters.empty? ? nil : JSON.parse(parameters[0..-1].join " ").values
        @procs[name].call name, *params
    end
end
