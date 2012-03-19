require_relative "../spec_helper.rb"

include TestHelper


describe Contact do

  before(:each) do
    
    @body = mock "body"
    @earth = mock "earth", :body => @body, :add_link => true
    @mars = mock "mars", :body => @body, :add_link => true
    
    @city = City.new("Houston", "Earth", @earth, @earth)
    @freeMars = Organisation.new("Free Mars", "Dedicated to Mars freedom", :proscribed, :fm)
    @freeMars.add_message(:poo, "Wo is me")
  end
  
  it "Get message back" do
   @freeMars.get_message(:poo).should == "Wo is me"
   @freeMars.get_message(:pat).should be_nil
  end
end