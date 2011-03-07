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
    @mars = mock "Mars"
    @ownerBody = mock "ownerbody", :body => @mars, :add_link => true
    @freeMars = Organisation.new("Free Mars", "Dedicated to Mars freedom", :proscribed)
    @contact = Contact.new("Jesper Nordstrum", "Collector of alien artefacts", @freeMars, @ownerBody)
    @city = City.new("Nicosia", "The first martian city to revolt against Earth imperium", @ownerBody)
    @city.add_contact(@contact,1)    
  end
  
  it "city has no available contacts - no mail sent from read" do
    @city.contacts.should be_empty
    SimpleBody.get_mail.should be_empty
  end
  
  it "contact trust score is organisations" do
    @contact.org.trust_score.should == 0
  end
  
  it "trust score is organisations" do
    @contact.org.trust 1
    @city.contacts.first.should == @contact 
    txt = SimpleBody.get_mail.last.txt
    txt.should include "added"
  end
 
  
  context "Visit Mars" do
    
    before(:each) do
      @city.visited           
    end
    
  end
end

