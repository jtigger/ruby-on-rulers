# lib/rulers/routing.rb
  
class Route
  def initialize
    @rules = []
  end
  
  def match(url, *args)
    puts "match(): url = #{url}, *args = #{args}"
    options = {}
    options = args.pop if args[-1].is_a?(Hash)
    options[:default] ||= {}
    
    dest = nil
    dest = args.pop if args.size > 0
    raise "Too many args!" if args.size > 0
    
    parts = url.split("/")
    parts.select! { |p| !p.empty? }
    
    vars = []
    regexp_parts = parts.map do |part|
      if part[0] == ":"
        vars << part[1..-1]
        "([a-zA-Z0-9]+)"
      elsif part[0] == "*"
        vars << part[1..-1]
        "(.*)"
      else
        part
      end
    end

    regexp = regexp_parts.join("/")
    @rules.push({
      :regexp => Regexp.new("^/#{regexp}$"),
      :vars => vars,
      :dest => dest,
      :options => options,
    })
  end
  
  def check_url(url)
    @rules.each do |rule|
      matches = rule[:regexp].match url
      
      if matches
        options = rule[:options]
        params = options[:default].dup
        rule[:vars].each_with_index do |var, idx|
          params[var] = matches.captures[idx]
        end
        dest = nil
        if rule[:dest]
          return get_dest(rule[:dest], params)
        else
          controller = params["controller"]
          action = params["action"]
          return get_dest("#{controller}##{action}", params)
        end
      end
    end
    nil
  end
  
  CONTROLLER_HASH_ACTION = /^(?<controller>[^#]+)#(?<action>[^#]+)$/
  def get_dest(dest, routing_params = {})
    return dest if dest.respond_to?(:call)
    if dest =~ CONTROLLER_HASH_ACTION
      controller_name = $~[:controller].capitalize
      action = $~[:action]
      controller = Object.const_get("#{controller_name}Controller")
      puts "dispatching to #{controller}##{action}; routing_params = #{routing_params}"
      return controller.rack_app_for(action, routing_params)
    end
    raise "No destination: #{dest.inspect}."
  end
end

module Rulers
  class Application
    def route(&block)
      @route ||= Route.new
      @route.instance_eval &block
    end
    
    def call(env)
      get_rack_app(env).call(env)
    end
    
    def get_rack_app(env)
      raise "No routes are defined." unless @route
      @route.check_url env["PATH_INFO"]
    end
  end
end