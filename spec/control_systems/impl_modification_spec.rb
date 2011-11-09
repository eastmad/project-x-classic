require_relative "../spec_helper.rb"

describe Modification do
  
  before :each do
    @mod = HeatShieldModule
    @modinst = @mod.new
  end
  
  context "When mod class available" do
    
    it "should have the right type" do
      @mod.superclass.should == Modification
    end
    
    it "should have the right type" do
      @mod.type.should == :shield
    end
       
    it "should get prinatble name" do
      @mod.name.should == "Heat Shield Module"
    end
    
  end
  
  context "When module instance available" do
    
    it "should have the right type" do
      @modinst.kind_of?(Modification).should == true
    end
    
    it "should have the right type" do
      @modinst.type.should == :shield
    end
       
    it "should get prinatble name" do
      @modinst.name.should == "Heat Shield Module"
    end
    
  end
 
end

describe ImplModification do
  
  before :each do
    @impl = ImplModification.new
    @mod1 = mock "HeatShield", :name => "Heat Shield Module"
    @modclass1 = mock "HeatShieldClass", :new => @mod1, :superclass => Modification
  end
 
  context "Where system or resources unavailable" do
 
    it "install should fail if target is of correct type" do
      target = mock "Turkey", :kind_of? => false, :new => nil, :superclass => nil
      expect { @impl.install target }.to raise_error(RuntimeError, "Not a module that can be installed")    
    end

  end
  
  context "Where system or resources available" do
 
    it "install should be of correct type" do
      @impl.install @modclass1
      @impl.mods.size.should == 1
      @impl.mods[0].name.should == "Heat Shield Module"
    end

  end
  
end