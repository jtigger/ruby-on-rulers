require "rulers/version"
require "rulers/routing"
require "rulers/array"

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
      
      klass, action = get_controller_and_action(env)
      controller = klass.new(env)
      reponse_body = controller.send(action)
      [200, {'Content-Type' => 'text/html'}, [reponse_body]]
    end
  end
  
  class Controller
    def initialize(env)
      @env = env
    end
    
    def env
      @env
    end
    
  end
end
