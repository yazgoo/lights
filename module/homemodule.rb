class HomeModule
    def action name, parameters, _proc
        @actions[name.to_s] = {
            :parameters => parameters,
            :proc => _proc
        }
    end
    def initialize
        @actions = {}
        setup
    end
    def call name, *parameters
        name = name.to_s
        return if @actions[name].nil?
        @actions[name][:proc].call(name, parameters[0])
    end
end
