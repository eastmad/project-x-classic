require "ship_system"
require "system_power"
require "system_weapon"
require "operation"
require "ship_registry"
require "ship_state_machine"
require "dictionary"
require "../simple_object_world/location_point.rb"
require "../simple_object_world/location_link.rb"
require "../simple_object_world/simple_body.rb"
require "../simple_object_world/simple_game_object.rb"

Shoes.app do
   info "Debug Operation"
   
   mySpaceStation = SpaceStation.new("Sputnik","Old soviet",LocationPoint.new("void","void"))
   @ship = ShipRegistry.register_ship("The Marco Polo", mySpaceStation.outerPoint)
   info @ship.describeLocation
   ShipSystem.christen(@ship)
   
   info ShipStateMachine.launch
   info ShipStateMachine.land
   info ShipStateMachine.land
   
   Operation.register_op :launch, :power, 1
   Operation.register_op :fire, :weapon, 1
   Operation.register_op :dock, :power, 1
   
    
   TestHelper.find_and_evaluate 'fire cannon at alien vessel'
   TestHelper.find_and_evaluate 'fire torpedoe at nearest vessel'
   TestHelper.find_and_evaluate 'attack police vessel'
   TestHelper.find_and_evaluate 'launch'
   TestHelper.find_and_evaluate 'launch probe'   
   TestHelper.find_and_evaluate 'dock'
   TestHelper.find_and_evaluate 'dock with station 4'        
end 


module TestHelper
   def self.find_and_evaluate(command_str)
      req_op = Operation.find_op_from_command(command_str)
      if !req_op
         warn "(No operation available - #{command_str})" 
         return
      end   
      my_sys = ShipSystem.find_system(req_op[:ship_system])   
      if !my_sys
         warn "(No system available - #{command_str})"
         return
      end
      resp_hash = my_sys.evaluate(command_str)
      info resp_hash[:str]
   end   
end