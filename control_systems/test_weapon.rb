require_relative "impl_weapon"
require_relative "../simple_object_world/trust_holder"
require_relative "../simple_object_world/trustee"
require_relative "../simple_object_world/simple_body"
require_relative "../simple_object_world/simple_game_object"

describe ImplWeapon do
  
  before :each do
    @impl = ImplWeapon.new 2
    @torpedo1 = mock "GovTorpedo", :yield => 4
    @torpedo2 = mock "WeakTorpedo", :yield => 3
    @torpedo3 = mock "BigTorpedo", :yield => 4
    @torpedoclass1 = mock "GovTorpedoClass", :new => @torpedo1
    @torpedoclass2 = mock "WeakTorpedoClass", :new => @torpedo2
    @torpedoclass3 = mock "BigTorpedoClass", :new => @torpedo3
  end
 
  context "Where system or resources unavailable" do
 
    it "destroy should fail if target is of correct type" do
      target = mock "Turkey", :kind_of? => false
      expect { @impl.destroy target }.to raise_error(RuntimeError, "Not a structure this weapon can target")    
    end

    it "destroy should fail if incorrect weapon installed" do
      target = mock "SmallStructure", :kind_of? => true
      expect { @impl.destroy target }.to raise_error(RuntimeError, "No torpedoes loaded")    
    end
        
  end
  
  context "Insufficient damage" do
    before :each do
      @impl.load_torpedo(@torpedoclass2)
    end
 
    it "a weak torpedo hits, but does not destroy" do
      target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4
      result = @impl.destroy target
      result.should < 0
    end
    
  end
  
  context "Sufficient damage" do
    before :each do
      @impl.load_torpedo(@torpedoclass3)
      @target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4, :status= => true
    end
 
    it "Correct torpedo hits, and destroy" do
      result = @impl.destroy @target
      result.should >= 0
    end
    
    it "torpedoe consumed whencorrect torpedo hits" do
      result = @impl.destroy @target
      @impl_torpedoes == 1
    end
    
    it "taget should be destroyed" do
      @target.should_receive(:status).and_return(:destroyed)
      result = @impl.destroy @target
      @target.status.should == :destroyed
    end

  end
end