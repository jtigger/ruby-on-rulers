# lib/rulers/routing.rb

module Rulers
  class Application
    def get_controller_and_action(request)
      _, controller_name, action, after = 
        request.path.split("/", 4)
        
      controller_name = controller_name.to_camel_case  # "MyPeople"
      controller_name += "Controller"                  # "MyPeopleController"
      
      if request.post?
        request[:id] = action.to_i
        action = "create"
      end
      
      [Object.const_get(controller_name), action]
    end
  end
end