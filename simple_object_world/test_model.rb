#model tests

require_relative "trust_holder"
require_relative "simple_body"
require_relative "simple_game_object"
require_relative "location_point"
require_relative "location_link"
require_relative "../control_systems/system_test_helper"

include TestHelper

  myStar = Star.new("Sol", "old star")
  otherStar = Star.new("Betelgeuse", "far star")
  myPlanet = myStar.planetFactory("Earth", "nice planet")
  myPlanetMars = myStar.planetFactory("Mars", "Very martian")
  mySpaceStation = myPlanet.stationFactory("Sputnik", "sputty") 
  
  puts "#{myPlanet.describe}"
  puts "#{myStar.describe}"
  puts "#{mySpaceStation.describe}"
  puts "#{myPlanetMars.describe}"

  puts "#{myStar} contains = "
  myStar.owns.each {|planet| puts planet.body.name}
  puts "#{myPlanet} contains = "
  myPlanet.owns.each {|sat| puts sat.body.name}
  #info "Is #{mySpaceStation} in #{myStar}? #{mySpaceStation.isLinked? myStar.outerPoint}"
 # info "Is #{mySpaceStation} in #{otherStar}? #{mySpaceStation.isLinked? otherStar.outerPoint}"
  
  sp = mySpaceStation.centrePoint
  info "Starting from #{sp}"  
