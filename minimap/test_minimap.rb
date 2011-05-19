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
  
    @mm = MiniMap.new
  end
  
  
  context "bad locpoint" do
    it "should fail to load" do
      expect {@mm.set_location_point "banana"}.to raise_error RuntimeError,"Not a locationPoint"
    end
  end
  
  context "for a location of Earth orbit" do
    before (:each) do
      @mm.set_location_point(@earth.orbitPoint)
    end
    
    it "should show Sol as top level object" do
      mmhash = @mm.top_level
      
      mmhash[:name].should == "Sol"
      mmhash[:image].should == "gifs/star_icon.gif"
    end
    
    it "should show current object as Earth" do
      mmhash = @mm.current_level
      
      mmhash[:name].should == "Earth"
      mmhash[:image].should == "gifs/planet_icon.gif"
    end
    
    it "should show option objects as satellites" do
      mmhasharray = @mm.option_level
      
      mmhasharray.size.should == 2
      mmhasharray[0][:name].should == "Sputnik"
      mmhasharray[0][:image].should == "gifs/spacestation_icon.gif"
      mmhasharray[1][:name].should == "OrbitalMall"
      mmhasharray[1][:image].should == "gifs/spacestation_icon.gif"
    end
    
  end
  
  context "for a location of Mars orbit" do
    before (:each) do
      @mm.set_location_point(@mars.orbitPoint)
    end
    
    it "should show Sol as top level object" do
      mmhash = @mm.top_level
      
      mmhash[:name].should == "Sol"
      mmhash[:image].should == "gifs/star_icon.gif"
    end
    
    it "should show current object as Earth" do
      mmhash = @mm.current_level
      
      mmhash[:name].should == "Mars"
      mmhash[:image].should == "gifs/planet_icon.gif"
    end
    
    it "should show option objects as satellites" do
      mmhasharray = @mm.option_level
      
      mmhasharray.size.should == 0
    end
    
  end
  
  context "for a location of Earth atmos" do
    before (:each) do
      @mm.set_location_point(@earth.atmospherePoint)
    end
    
    it "should show Sol as top level object" do
      mmhash = @mm.top_level
      
      mmhash[:name].should == "Sol"
      mmhash[:image].should == "gifs/star_icon.gif"
    end
    
    it "should show current object as Earth" do
      mmhash = @mm.current_level
      
      mmhash[:name].should == "Earth"
      mmhash[:image].should == "gifs/planet_icon.gif"
    end
    
    it "should show option objects as cities" do
      mmhasharray = @mm.option_level
      
      mmhasharray.size.should == 1
      mmhasharray[0][:name].should == "Houston"
      mmhasharray[0][:image].should == "gifs/city_icon.gif"
    end
    
  end
  
  context "for a location of Mars atmos" do
    before (:each) do
      @mm.set_location_point(@mars.atmospherePoint)
    end
    
    it "should show Sol as top level object" do
      mmhash = @mm.top_level
      
      mmhash[:name].should == "Sol"
      mmhash[:image].should == "gifs/star_icon.gif"
    end
    
    it "should show current object as Mars" do
      mmhash = @mm.current_level
      
      mmhash[:name].should == "Mars"
      mmhash[:image].should == "gifs/planet_icon.gif"
    end
    
    it "should show option objects as cities" do
      mmhasharray = @mm.option_level
      
      mmhasharray.size.should == 2
      mmhasharray[0][:name].should == "Dundarach"
      mmhasharray[0][:image].should == "gifs/city_icon.gif"
      mmhasharray[1][:name].should == "Nicosia"
      mmhasharray[1][:image].should == "gifs/city_icon.gif"
    end
    
  end

end  
