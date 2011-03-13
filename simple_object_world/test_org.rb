require "./location_link"
require "./location_point"
require "./simple_body.rb"
require "./contact.rb"
require "./trader.rb"
require "./simple_game_object.rb"
require "../control_systems/system_test_helper"
include TestHelper


describe Contact do

  before(:each) do
    
    @body = mock "body"
    @earth = mock "earth", :body => @body, :add_link => true
    @mars = mock "mars", :body => @body, :add_link => true
    
    @city = City.new("Houston", "Earth", @earth)
    @freeMars = Organisation.new("Free Mars", "Dedicated to Mars freedom", :proscribed)
    @freeMars.add_message(:poo, "Wo is me")
  end
  
  it "Get message back" do
   @freeMars.get_message(:poo).should == "Wo is me"
   @freeMars.get_message(:pat).should be_nil
  end
end