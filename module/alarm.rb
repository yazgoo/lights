require 'cronedit'
class Alarm < HomeModule
    def get_cronvalues i = nil
        value = CronEdit::Crontab.new.list[@name]
        return nil if value.nil?
        values = value.split "\t"
        return values if i.nil?
        if i == :hour or i == :minute
            values[i == :hour ? 1 : 0].to_i
        else
            values.last
        end
    end
    def set_cronvalues hour, minute, command
        crontab = CronEdit::Crontab.new
        crontab.add @name, {:minute => minute, :hour => hour, :command=> command}
        crontab.commit
    end
    def setup
        @name = @params
        alarm = get_cronvalues
        set_cronvalues 9, 15, "echo 42" if alarm.nil?
        action :set, {:parameters => {
            :hour => {:type => :range, :start => 0, :end => 23, :step => 1,
                :default => Proc.new {get_cronvalues :hour}},
            :minute => {:type => :range, :start => 0, :end => 59, :step => 5,
                :default => Proc.new {get_cronvalues :minute}},
            :command => {:type => :string, :default => Proc.new {get_cronvalues :command}}
        }},
            Proc.new { |name, hour, minute, command|
            puts "set #{name}, #{hour} #{minute}"
            set_cronvalues hour, minute, command
        }
    end
end

