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
          begin
            response_body = controller.send(action)
            controller.render_response unless response_body
            if controller.response
              status, header, response = controller.response.to_a
              [status, header, [response.body].flatten]
            else
              [200, {'Content-Type' => 'text/html'}, [response_body]]
            end
          rescue Exception => e
            error_html = "<pre>" + e.message + "\n" + e.backtrace.join("\n") + "</pre>"
            return [500, {'Content-Type' => 'text/html'}, [error_html]]
          end
      end
    end
  end
end
