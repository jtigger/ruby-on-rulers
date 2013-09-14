# lib/rulers/routing.rb

module Rulers
  class Application
    def get_controller_and_action(request)
      _, controller, action, after = 
        request.fullpath.split("/", 4)
        
      controller = controller.capitalize   # "People"
      controller += "Controller"           # "PeopleController"
      
      if request.post?
        request[:id] = action.to_i
        action = "create"
      end
      
      [Object.const_get(controller), action]
    end
  end
end