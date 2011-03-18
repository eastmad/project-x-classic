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
    
    @city = City.new("Houston", "Earth", @earth, @earth)
    @freeMars = Organisation.new("Free Mars", "Dedicated to Mars freedom", :proscribed)
    @contact = @city.contactFactory(:Jesper, "Nordstrum", "Collector of alien artefacts", @freeMars, 1)
    @contact2 = @city.contactFactory(:Per, "Persen", "Tax inspector", @freeMars, 2)
        
  end
  
  it "city has no available contacts - no mail sent from read" do
    @city.contacts.should be_empty
    SimpleBody.get_mail.should be_empty
    @city.describe_owns.should include "No known contacts"
  end
  
  it "contact trust score is organisations, and is 0" do
    @contact.org.trust_score.should == 0
    @city.contacts.size.should == 0
  end
  
  it "contact added if trust goes up by one" do
    @contact.org.trust 1
    @city.contacts.size.should == 1
    @city.contacts.last.should == @contact
    @city.describe_owns.should include "Jesper Nordstrum"
    @city.describe_owns.should_not include "Per Persen"
  end
  
  it "two contact added if trust goes up by two" do
    @contact.org.trust 2
    @city.contacts.size.should == 2
    @city.contacts.last.should == @contact2
    @city.describe_owns.should include "Jesper Nordstrum"
    @city.describe_owns.should include "Per Persen"
  end
  
  context "Visit Mars" do
    
    before(:each) do
      @visit_city = City.new("Nicosia", "The first martian city to revolt against Earth imperium", @mars, @mars)
      @visit_city.add_visit_trigger(@freeMars,1)
    end
    
    it "no contact added if no visit" do
      @city.contacts.should be_empty
    end
  
    it "contact added if trust goes up by one" do
      @visit_city.visit
      @city.contacts.last.should == @contact
      @city.contacts.size.should == 1
      SimpleBody.get_mail.should be_empty
      @city.describe_owns.should include "Jesper Nordstrum"
    end
    
    it "subsequent visits don't add more" do
      @visit_city.visit
      @visit_city.visit
      @city.contacts.size.should == 1 
    end
    
    
    it "UPDATED only once" do
      @visit_city.visit
      @city.describe_owns.should include "UPDATED"
      @city.describe_owns.should_not include "UPDATED"
    end  
  end
end

