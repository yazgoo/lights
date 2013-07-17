class Heyu < HomeModule
    def setup
        config = "#{ENV['HOME']}/.heyu/x10config"
        heyu = "#{ENV['HOME']}/dev/heyu-2.11-rc1/heyu -c #{config}"
        File.open config do |f|
            f.each_line do |line|
                if line =~ /^ALIAS\s/
                    p line
                    line = line.split
                    {"on" => "", "off" => "-blank"}.each do |k, v|
                        action line[1]+"_"+k, {:icon => 'circle'+v},
                            Proc.new { p `#{heyu} #{k} #{line[2]}` }
                    end
                end
            end
        end
    end
end

