require "ship_system"
require "system_power"
require "system_weapon"
require "operation"
require "ship_registry"

Shoes.app do
   info "Debug Operation"
   
   @ship = ShipRegistry.register_ship("The Marco Polo")
   ShipSystem.christen(@ship)
   
   Operation.register_op :launch, :power, 1
   my_op = Operation.find_op(:launch)
   
   Operation.register_op :fire, :weapon, 1
   my_op1 = Operation.find_op(:fire)   
   
   req = 'fire cannon at alien vessel'
   command_verb = req.split.first
   req_op = Operation.find_op(command_verb.to_sym)
   
   my_sys = ShipSystem.find_system(my_op[:ship_system])   
   info my_sys.evaluate("launch")
   info my_sys.evaluate("launch probe")
   info my_sys.evaluate("dock")
   info my_sys.evaluate("dock with station 4")
   
   my_sys = ShipSystem.find_system(req_op[:ship_system])   
   info my_sys.evaluate("fire torpedoe at nearest vessel")
   info my_sys.evaluate(req)
   info my_sys.evaluate("attack police vessel")
   
end 