require "ship_system"
require "dictionary"
require "operation"
require "../interface/system_message"
require "../interface/response_queue"
require "system_power"
require "system_weapon"
require "system_security"
require "system_trade"
require "system_navigation"
require "system_communication"
require "system_myself"
require "system_library"

require "ship_data"
require "ship_registry"
require "../simple_object_world/location_point.rb"
require "../simple_object_world/location_link.rb"
require "../simple_object_world/simple_body.rb"
require "../simple_object_world/simple_game_object.rb"
require "system_test_helper"

include TestHelper

rq = ResponseQueue.new
ShipSystem.set_rq rq

myStar = Star.new("Star","hot")
mySpaceStation = myPlanet.stationFactory("Sputnik","Old soviet")
myPlanet = myStar.planetFactory("Earth","Nowehere")
myCity = myPlanet.cityFactory("Houston","Old soviet")

@ship = ShipRegistry.register_ship("ProjectX",mySpaceStation.surfacePoint)
ShipSystem.christen(@ship)
   
Operation.register_op :launch, :power, 1

puts "\n#{@ship.describeLocation}"
test_command 'launch', rq

ShipSystem.christen(@ship = ShipRegistry.register_ship("ProjectX",myPlanet.surfacePoint))
puts "\n#{@ship.describeLocation}"      
test_command 'launch', rq

ShipSystem.christen(@ship = ShipRegistry.register_ship("ProjectX",myCity.centrePoint))
puts "\n#{@ship.describeLocation}"
test_command 'launch', rq

ShipSystem.christen(@ship = ShipRegistry.register_ship("ProjectX",myPlanet.atmospherePoint))
puts "\n#{@ship.describeLocation}"
test_command 'launch', rq


