# lib/rules/controller.rb
require "erubis"
require "rulers/model"

module Rulers
  class Controller
    include Rulers::Model
    attr_reader :request
    attr_reader :response
    
    def initialize(env)
      @request = Rack::Request.new(env)
      @routing_params = {}
    end
    
    def self.rack_app_for(action, request_params = {})
      proc { |env| self.new(env).dispatch(action, request_params) }
    end
    
    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      response_body = self.send(action)
      self.render_response action unless response_body
      if self.response
        status, header, response = self.response.to_a
        [status, header, [response.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [response_body]]
      end
    end
    
    def params
      @request.params.merge @routing_params
    end
    
    def name
      Rulers.to_snakecase self.class.to_s.gsub /Controller$/, ''
    end
    
    def get_template_contents(view_name)
      filename = File.join "app", "views", self.name, "#{view_name}.html.erb"
      File.read filename
    end
    
    def render_response(*args)
      response_body = render(*args)
      respond(response_body)
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
    
    def respond(text, status = 200, headers = {})
      raise "Attempting to respond to a request that was already responded to. " +
            "(existing response = #{response.inspect}; this response text = #{text})" if @response
            
      body = [text].flatten
      @response = Rack::Response.new(body, status, headers)
    end
  end
end
