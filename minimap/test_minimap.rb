require_relative "../simple_object_world/location_link"
require_relative "../simple_object_world/location_point"
require_relative "../simple_object_world/trustee"
require_relative "../simple_object_world/trust_holder"
require_relative "../simple_object_world/simple_body"
require_relative "../simple_object_world/simple_game_object"
require_relative "../simple_object_world/city"
require_relative "../control_systems/system_test_helper"
require_relative "mini_map"
include TestHelper

describe MiniMap do

  before(:each) do
    @sol = Star.new("Sol", "Your home planet's sun")
    @earth = @sol.planetFactory("Earth","Your home planet")
    @mars = @sol.planetFactory("Mars", "Known as the red planet")
    
    @sputnik = @earth.stationFactory("Sputnik", "One of the oldest space stations")
    @mall = @earth.stationFactory("OrbitalMall", "A Modern trading space stations")

    @houston =  @earth.cityFactory("Houston", "Main space port for Earth, based in old continental America")
    @marsport = @mars.cityFactory("Dundarach", "Only space port for Mars, sometimes referred to as Marsport")
    @nicosia = @mars.cityFactory("Nicosia", "Now deserted city, location of the first Mars independence revolt.")
  
    @mm = MiniMap.new(@sol)
  end
  
  context "bad root" do
    it "should fail to load" do
      expect {MiniMap.new "banana"}.to raise_error RuntimeError,"Not a body"
    end  
  end
  
  context "for a location of Earth orbit" do
    before (:each) do
      @mm.setLocationPoint(@earth.orbitPoint)
    end
    
    it "should show Sol as top level object" do
      mmhash = @mm.topLevel
      
      mmhash[:name].should == "Sol"
      mmhash[:image].should == "gifs/star_icon.gif"
    end
    
    it "should show current object as Earth" do
      mmhash = @mm.currentLevel
      
      mmhash[:name].should == "Earth"
      mmhash[:image].should == "gifs/planet_icon.gif"
    end
    
    it "should show option objects as satellites" do
      mmhasharray = @mm.optionLevel
      
      mmhasharray.size.should == 2
      mmhasharray[0][:name].should == "Sputnik"
      mmhasharray[0][:image].should == "gifs/sat_icon.gif"
      mmhasharray[1][:name].should == "OrbitalMall"
      mmhasharray[1][:image].should == "gifs/sat_icon.gif"
    end
    
  end

end  
