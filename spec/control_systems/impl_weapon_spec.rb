require_relative "../spec_helper.rb"

describe Torpedo do
  
  before :each do
    @torp = Torpedo
    @govtorp = GovTorpedo
  end
  
  context "When torpedo class available" do
    
    it "should have the right type" do
      @torp.type.should == :torpedo
    end
    
    it "should get yield" do
      @torp.yield.should == 1
    end
    
    it "should get prinatble name" do
      @torp.name.should == "Basic Torpedo"
    end
    
  end
  
  context "When govtorpedo class available" do
    
    it "should have the right type" do
      @govtorp.type.should == :torpedo
    end
    
    it "should get yield" do
      @govtorp.yield.should == 2
    end
    
    it "should get prinatble name" do
      @govtorp.name.should == "Standard issue torpedo"
    end
    
  end
  
  context "When torpedo instance available" do
    
    before :each do
      @torp_inst = Torpedo.new
    end

    it "should get yield" do
      @torp_inst.yield.should == 1
    end
    
    it "should get prinatble name" do
      @torp_inst.name.should == "Basic Torpedo"
    end

  end
  
  context "When govtorpedo instance available" do
    
    before :each do
      @torp_inst = GovTorpedo.new
    end

    it "should get yield" do
      @torp_inst.yield.should == 2
    end
    
    it "should get prinatble name" do
      @torp_inst.name.should == "Standard issue torpedo"
    end

  end
end

describe ImplWeaponry do
  
  before :each do
    @impl = ImplWeaponry.new 2
    @torpedo1 = mock "GovTorpedo", :yield => 2
    @torpedo2 = mock "WeakTorpedo", :yield => 3
    @torpedo3 = mock "BigTorpedo", :yield => 4
    @torpedo4 = mock "BiggerTorpedo", :yield => 5
    @torpedoclass1 = mock "GovTorpedoClass", :new => @torpedo1, :yield => 2
    @torpedoclass2 = mock "WeakTorpedoClass", :new => @torpedo2, :yield => 3
    @torpedoclass3 = mock "BigTorpedoClass", :new => @torpedo3
    @torpedoclass4 = mock "BiggerTorpedoClass", :new => @torpedo4
  end
 
  context "Where system or resources unavailable" do
 
    it "destroy should fail if target is of correct type" do
      target = mock "Turkey", :kind_of? => false, :status => :normal
      @impl.destroy(target).should == -1 
    end

    it "destroy should fail no weaponry loaded" do
      target = mock "SmallStructure", :kind_of? => true, :status => :normal
      @impl.destroy(target).should == -1    
    end
       
  end
  
  context "Insufficient damage" do
    before :each do
      @impl.load_torpedoes(@torpedoclass2)
    end
 
    it "a weak torpedo hits, but does not destroy" do
      target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4, :status => :normal
      result = @impl.destroy target
      result.should < 0
    end
    
  end
  
  context "When sufficient damage to disable" do
    before :each do
      @impl.load_torpedoes(@torpedoclass3)
      @target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4, :status => :normal
      @target.should_receive(:status=).with(:disabled)
    end
 
    it "correct torpedo hits, does damage difference 0" do
      result = @impl.destroy @target
      result.should == 0
    end
    
    it "torpedoe consumed when fired" do
      result = @impl.destroy @target
      @impl.torpedoes.size.should == 1
    end

  end
  
  context "when sufficient damage to destroy" do
    before :each do
      @impl.load_torpedoes(@torpedoclass4)
      @target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4, :status => :normal
      @target.should_receive(:status=).with(:destroyed)
    end
 
    it "Correct torpedo hits, does damage difference 1" do
      result = @impl.destroy @target
      result.should == 1
    end
    
    it "torpedoe consumed when fired" do
      result = @impl.destroy @target
      @impl.torpedoes.size.should == 1
    end

  end

  context "When loading missiles" do
    it "should load missiles to max" do
      @impl.load_torpedoes(@torpedoclass1)
      @impl.torpedoes.size.should == 2
      @impl.torpedoes[0].yield.should == 2
      @impl.torpedoes[1].yield.should == 2
    end
    
    it "should replace inferior missiles" do
      @impl.load_torpedoes(@torpedoclass1)
      @impl.load_torpedoes(@torpedoclass2)
      @impl.torpedoes[0].yield.should == 3
      @impl.torpedoes[1].yield.should == 3
    end
    
    it "should not replace superior missiles" do
      @impl.load_torpedoes(@torpedoclass2)
      @impl.load_torpedoes(@torpedoclass1)
      @impl.torpedoes[0].yield.should == 3
      @impl.torpedoes[1].yield.should == 3
    end
    
    it "will add if needed" do
      @impl.load_torpedoes(@torpedoclass2)
      @target = mock "SmallStructure", :kind_of? => true, :damage_rating => 4, :status => :normal
      @impl.destroy @target
      #@target.should_receive(:status=).with(:disabled)
      
      @impl.load_torpedoes(@torpedoclass1)
      @impl.torpedoes[0].yield.should == 3
      @impl.torpedoes[1].yield.should == 2
    end
  end
end