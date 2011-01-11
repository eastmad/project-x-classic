#model tests

require "simple_body"
require "simple_game_object"
require "location_point"
require "location_link"


Shoes.app do
  myStar = Star.new("Sol")
  otherStar = Star.new("Betelgeuse")
  myPlanet = Planet.new("Earth", myStar.outerPoint)
  myPlanetMars = Planet.new("Mars", myStar.outerPoint)
  mySpaceStation = SpaceStation.new("Sputnik", myPlanet.orbitPoint) 
  
  info "#{myPlanet.describe}"
  info "#{myStar.describe}"
  info "#{mySpaceStation.describe}"
  info "#{myPlanetMars.describe}"

  info "#{myStar} contains = #{myStar.owns}"
  info "#{myPlanet} contains = #{myPlanet.owns}"
  #info "Is #{mySpaceStation} in #{myStar}? #{mySpaceStation.isLinked? myStar.outerPoint}"
 # info "Is #{mySpaceStation} in #{otherStar}? #{mySpaceStation.isLinked? otherStar.outerPoint}"
  
  sp = mySpaceStation.centrePoint
  info "Starting from #{sp}"
  sp = sp.out
  info "Outwards is #{sp}"
  
end   
