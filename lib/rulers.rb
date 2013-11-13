# rulers/lib/rulers.rb
require "rack"
require "require_all"
require_rel "rulers"

module Rulers
  class Application
    def call(env)
      request = Rack::Request.new env
      case request.path
        when '/favicon.ico'
          return [404, {'Content-Type' => 'text/html'}, []]
          
        when '/'
          return [302, {'Location' => '/home/index'}, []]
          
        else
          klass, action = get_controller_and_action request
          rack_app = klass.rack_app_for action
          begin
            rack_app.call env
          rescue Exception => e
            error_html = "<pre>" + e.message + "\n" + e.backtrace.join("\n") + "</pre>"
            return [500, {'Content-Type' => 'text/html'}, [error_html]]
          end
      end
    end
  end
end
