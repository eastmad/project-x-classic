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
    @torpedo4 = mock "BiggerTorpedo", :yield => 5
    @torpedoclass1 = mock "GovTorpedoClass", :new => @torpedo1
    @torpedoclass2 = mock "WeakTorpedoClass", :new => @torpedo2
    @torpedoclass3 = mock "BigTorpedoClass", :new => @torpedo3
    @torpedoclass4 = mock "BiggerTorpedoClass", :new => @torpedo4
  end
 
  context "Where system or resources unavailable" do
 
    it "destroy should fail if target is of correct type" do
      target = mock "Turkey", :kind_of? => false, :status => :normal
      expect { @impl.destroy target }.to raise_error(RuntimeError, "Not a structure this weapon can target")    
    end

    it "destroy should fail if incorrect weapon installed" do
      target = mock "SmallStructure", :kind_of? => true, :status => :normal
      expect { @impl.destroy target }.to raise_error(RuntimeError, "No torpedoes loaded")    
    end
    
    it "destroy should fail if target is already destroyed" do
      target = mock "SmallStructure", :kind_of? => true, :status => :destroyed
      expect { @impl.destroy target }.to raise_error(RuntimeError, "Structure has insufficient integrity to target")    
    end
        
  end
  
  context "Insufficient damage" do
    before :each do
      @impl.load_torpedo(@torpedoclass2)
    end
 
    it "a weak torpedo hits, but does not destroy" do
      target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4, :status => :normal
      result = @impl.destroy target
      result.should < 0
    end
    
  end
  
  context "When sufficient damage to disable" do
    before :each do
      @impl.load_torpedo(@torpedoclass3)
      @target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4, :status => :normal
      @target.should_receive(:status=).with(:disabled)
    end
 
    it "correct torpedo hits, does damage difference 0" do
      result = @impl.destroy @target
      result.should == 0
    end
    
    it "torpedoe consumed when fired" do
      result = @impl.destroy @target
      @impl_torpedoes == 1
    end

  end
  
  context "when sufficient damage to destroy" do
    before :each do
      @impl.load_torpedo(@torpedoclass4)
      @target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4, :status => :normal
      @target.should_receive(:status=).with(:destroyed)
    end
 
    it "Correct torpedo hits, does damage difference 1" do
      result = @impl.destroy @target
      result.should == 1
    end
    
    it "torpedoe consumed when fired" do
      result = @impl.destroy @target
      @impl_torpedoes == 1
    end

  end

  
end