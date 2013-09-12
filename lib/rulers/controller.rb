# lib/rules/controller.rb
require "erubis"

module Rulers
  class Controller
    def initialize(env)
      @env = env
    end

    def env
      @env
    end
    
    def render(view_name, locals = {})
      filename = File.join("app", "views", self.name, "#{view_name}.html.erb")
      template = File.read(filename)
      eruby = Erubis::Eruby.new(template)
      eruby.result(locals.merge(:env => env))
    end
    
    def name
      Rulers.to_underscore self.class.to_s.gsub /Controller$/, ''
    end
  end
end
