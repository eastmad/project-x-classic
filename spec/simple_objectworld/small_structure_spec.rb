require_relative "../spec_helper.rb"

describe SmallStructure do
  before(:each) do
    @earth = mock "earth", :body => @body, :add_link => true
    @sm = SmallStructure.new("test", "test", @earth, 2, :test)
    @trustee = mock "Trustee", :kind_of? => true
    @nontrustee = mock "Trustee", :kind_of? => false
  end
  
  after(:each) do
    SimpleBody.clear_ref
  end
  
  it "can add a trustee death_listener" do
    @sm.add_death_listener @trustee
  end
  
  it "cannot add a non-trustee death_listener" do
    expect {@sm.add_death_listener @nontrustee}.to raise_error(RuntimeError, "Not a trustee")
  end
  
  context "with a @trustee added" do
    before :each do
      @sm.add_death_listener @trustee
    end  
    
    it "status is normal" do
      @sm.status.should == :normal
    end
    
    it "status change detected" do
      @trustee.should_receive(:trust).with(1)
      @sm.status = :destroyed
    end
    
    it "status not change ignored" do
      @trustee.should_not_receive(:trust)
      @sm.status = :normal
    end    
  end
end
