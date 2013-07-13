class Tcp < HomeModule
    def setup
        @name = @params[:name]
        @params[:messages].each do |name, message|
            action name, {:icon => message[:icon]}, Proc.new { |name|
                arduino = TCPSocket.new @params[:host], @params[:port]
                arduino.puts message[:message]
                arduino.close
            }
        end
    end
end
