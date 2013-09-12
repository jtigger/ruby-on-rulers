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
    
    def get_template_contents(view_name)
      filename = File.join "app", "views", self.name, "#{view_name}.html.erb"
      File.read filename
    end
    
    def render(view_name, locals = {})
      template = get_template_contents view_name
      eruby = Erubis::Eruby.new template
      eruby.result locals.merge :env => env
    end
    
    def name
      Rulers.to_snakecase self.class.to_s.gsub /Controller$/, ''
    end
  end
end
