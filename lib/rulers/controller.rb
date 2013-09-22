# lib/rules/controller.rb
require "erubis"
require "rulers/file_model"

module Rulers
  class Controller
    include Rulers::Model

    def initialize(request)
      @request = request
    end

    def request
      @request
    end
    
    def get_template_contents(view_name)
      filename = File.join "app", "views", self.name, "#{view_name}.html.erb"
      File.read filename
    end
    
    def render(view_name, locals = {})
      template = get_template_contents view_name
      eruby = Erubis::Eruby.new template
      
      template_context = locals
      self.instance_variables.each { |ivar_name|
        template_context[ivar_name.to_s.delete("@").to_sym] = self.instance_variable_get(ivar_name) 
      }
      template_context[:request] = request

      eruby.result template_context
    end
    
    def name
      Rulers.to_snakecase self.class.to_s.gsub /Controller$/, ''
    end
  end
end
