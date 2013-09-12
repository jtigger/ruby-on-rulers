# rulers/lib/rulers.rb
require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"

module Rulers
  class Application
    def call(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
      
      klass, action = get_controller_and_action(env)
      controller = klass.new(env)
      begin
        reponse_body = controller.send(action)
      rescue Exception => e
        return [500, {'Content-Type' => 'text/html'}, ["Error occurred."]]
      end
      
      [200, {'Content-Type' => 'text/html'}, [reponse_body]]
    end
  end
end
