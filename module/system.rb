class System < HomeModule
    def setup
        @name = @params[:name]
        @params[:commands].each do |name, command|
            action name, {:icon => command[:icon]}, Proc.new { |name|
                system command[:command]
            }
        end
    end
end
