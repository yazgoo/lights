load "#{File.dirname __FILE__}/homemodule.rb"
class Alarm < HomeModule
    def setup
        action :set, {:parameters => {
            :hour => {:type => :integer, :default => 9},
            :minute => {:type => :integer, :default => 15}}},
            Proc.new { |name, path|
            puts "set"
        }
    end
end

