#model tests

require "trust_holder"
require "simple_body"
require "simple_game_object"
require "location_point"
require "location_link"
require "../control_systems/system_test_helper"

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
