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
    
    @city = City.new("Houtson", "Earth", @earth)
    @freeMars = Organisation.new("Free Mars", "Dedicated to Mars freedom", :proscribed)
    @contact = @city.contactFactory("Jesper Nordstrum", "Collector of alien artefacts", @freeMars, 1)
    @contact2 = @city.contactFactory("Per Persen", "Tax inspector", @freeMars, 2)
    
    @visit_city = City.new("Nicosia", "The first martian city to revolt against Earth imperium", @mars)
        
  end
  
  it "city has no available contacts - no mail sent from read" do
    @city.contacts.should be_empty
    SimpleBody.get_mail.should be_empty
  end
  
  it "contact trust score is organisations, and is 0" do
    @contact.org.trust_score.should == 0
  end
  
  it "contact added if trust goes up by one" do
    @contact.org.trust 1
    @city.contacts.first.should == @contact 
    txt = SimpleBody.get_mail.last.txt
    txt.should include "Jesper Nordstrum added"
  end
  
  it "two contact added if trust goes up by two" do
    @contact.org.trust 2
    @city.contacts.last.should == @contact2 
    txt = SimpleBody.get_mail.last.txt
    txt.should include "Per Persen added"
  end
  
  context "Visit Mars" do
    
    before(:each) do
      @visit_city.add_visit_trigger(@freeMars,1)
    end
    
    it "no contact added if no visit" do
      @city.contacts.should be_empty
    end
  
    it "contact added if trust goes up by one" do
      @visit_city.visit
      @city.contacts.first.should == @contact 
      txt = SimpleBody.get_mail.last.txt
      txt.should include "added"
    end
    
    it "subsequent visits don't add more" do
      @visit_city.visit
      @visit_city.visit
      @city.contacts.size.should == 1 
    end
  end
end

