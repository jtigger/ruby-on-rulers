# rulers/lib/rulers.rb
require "rack"
require "require_all"
require_rel "rulers"

module Rulers
  class Application
    def call(env)
      request = Rack::Request.new(env)

      case request.path
        when '/favicon.ico'
          return [404, {'Content-Type' => 'text/html'}, []]
          
        when '/'
          return [302, {'Location' => '/home/index'}, []]
          
        else
          klass, action = get_controller_and_action(request)
          controller = klass.new(request)
          # begin
            reponse_body = controller.send(action)
            [200, {'Content-Type' => 'text/html'}, [reponse_body]]
          # rescue Exception => e
          #   return [500, {'Content-Type' => 'text/html'}, [e.inspect]]
          # end
      end
    end
  end
end
