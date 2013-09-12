# rulers/lib/rulers.rb
require "rulers/version"
require "rulers/routing"
require "rulers/util"
require "rulers/dependencies"
require "rulers/controller"

module Rulers
  class Application
    def call(env)
      case env['PATH_INFO']
      when '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      when '/'
        return [302, {'Location' => '/home/index'}, []]
      else
        klass, action = get_controller_and_action(env)
        controller = klass.new(env)
        begin
          reponse_body = controller.send(action)
          [200, {'Content-Type' => 'text/html'}, [reponse_body]]
        rescue Exception => e
          return [500, {'Content-Type' => 'text/html'}, [e.inspect]]
        end
      end
    end
  end
end
