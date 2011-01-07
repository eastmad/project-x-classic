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
  myMoon = Moon.new("Sputnik", myPlanet.orbitPoint) 
  
  info "#{myPlanet.describe}"
  info "#{myStar.describe}"
  info "#{myMoon.describe}"
  info "#{myPlanetMars.describe}"

  info "#{myStar} contains = #{myStar.owns}"
  info "#{myPlanet} contains = #{myPlanet.owns}"
  #info "Is #{myMoon} in #{myStar}? #{myMoon.isLinked? myStar.outerPoint}"
 # info "Is #{myMoon} in #{otherStar}? #{myMoon.isLinked? otherStar.outerPoint}"
  
  sp = myMoon.centrePoint
  info "Starting from #{sp}"
  sp = sp.out
  info "Outwards is #{sp}"
  
end   
