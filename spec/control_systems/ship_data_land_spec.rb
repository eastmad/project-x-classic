require_relative "../spec_helper.rb"

class SystemPower
end

class SystemNavigation
end

describe ShipData do
  
  context "Not by a celestial body" do
  
    before :each do
      @body = SimpleBody.new("TestOwnerBody")
      @locPoint = LocationPoint.new(@body, :centre)
      
      @ship = ShipData.new("TestX",@locPoint)
      @ship.stub!(:info)
    end
    
    context "call land" do
      it "should raise as no :land links" do
        @body.stub!(:available_city).and_return(nil)
        expect {@ship.land(@body)}.to raise_error(SystemsMessage, "No space ports found") 
      end
      
      it "should return SystemMessage if available" do
        @body.stub!(:available_city).and_return(@locPoint)
        
        @ship.land(@body).to_s.should == "Landed at TestOwnerBody" 
      end
    end
    
    context "call land_need_approach?" do
       
      before :each do
        @unrelated_body = SimpleBody.new("TestUnrelatedBody")
        @unrelated_loc = LocationPoint.new(@unrelated_body, :centre) 
      end
    
      after :each do
        SimpleBody.clear_ref
      end 
       
      it "should raise with nil" do
        expect {@ship.land_need_approach?(nil)}.to raise_error(SystemsMessage, "You can only land at a city space port") 
      end
      
      it "should raise with non-Planet/City" do
        expect {@ship.land_need_approach?(@unrelated_body)}.to raise_error(SystemsMessage, "You can only land at a city space port") 
      end
      
      it "should raise with target Planet not where TestX is" do
        planet = Planet.new("TestPlanet","Test", @unrelated_loc)
        expect {@ship.land_need_approach?(planet)}.to raise_error(SystemsMessage, "TestX is above TestOwnerBody not TestPlanet") 
      end
      
      it "should return true for target City not reachable from TestX is" do
        city = City.new("TestCity","Test", @unrelated_loc, :tc)
        @ship.land_need_approach?(city).should be_true
      end
      
      it "should return false for target City where a place to land is reachable to TestX" do
        @locPoint.add_link([:land], nil) #so the status is set to dependent
        @ship = ShipData.new("TestX",@locPoint)
        city = City.new("TestCity","Test", @unrelated_loc, :tc)
        @ship.land_need_approach?(city).should be_false
      end
      
      it "should raise if we have landed" do
        @locPoint.add_link([:launch], nil) #so the status is set to dependent
        @ship = ShipData.new("TestX",@locPoint)
        
        city = City.new("TestCity","Test", @unrelated_loc, :tc)
        expect {@ship.land_need_approach?(city)}.to raise_error(SystemsMessage, "TestX is already stationary") 
      end
    end
  end 
end