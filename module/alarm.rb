load "#{File.dirname __FILE__}/homemodule.rb"
class Alarm < HomeModule
    def setup
        action :set, {:parameters => {
            :hour => {:type => :range, :start => 0, :end => 23, :step => 1, :default => 9},
            :minute => {:type => :range,
                :default => 15, :start => 0, :end => 59, :step => 5}}},
            Proc.new { |name, parameters|
            puts "set #{name}, #{parameters["hour"]} #{parameters["minute"]}"
        }
    end
end

