require_relative "trust_holder"
require_relative "trustee"
require_relative "../control_systems/system_test_helper"

class TrusteeMock
  include Trustee
  
  attr_reader :things
  
  def initialize(name)
    @name = name
    @things = []
  end
  
  def to_s
   "trust mock #{@name}"
  end
end

class TrustHolderMock
  include TrustHolder
  
  attr_reader :things
  
  def initialize(name)
    @name = name
    @things = []
  end
  
  def things
    check_trust_list
    @things
  end
  
  def add_to_list(trust,obj)
    add_to_trust_list(trust, obj,  nil)
  end

  def to_s
   "trust mock #{@name}"
  end
  
  private
  
  def horizon (trust,obj, trustee)
    false
  end
end

class TrustHolderAndTrusteeMock
  include TrustHolder
  include Trustee
  
  attr_reader :things
  
  def initialize(name)
    @name = name
    @things = []
  end
  
  def things
    check_trust_list
    @things
  end
  
  def add_to_list(trust,obj)
    add_to_trust_list(trust, obj, nil)
  end

  def to_s
   "trust mock #{@name}"
  end
  
  private
  
  def horizon (trust, obj, trustee = nil)
    if trust <= trust_score
      @things << obj
      return true
    end
    
    return false
  end
end


describe "Trustee" do

  context "trust holder maintains trust " do
    before(:each) do
      @tm = TrusteeMock.new("Poo")
    end  
      
    it "trust score should be 0" do
      @tm.trust_score.should == 0
    end
  
    it "trust score should be 1" do
      @tm.trust(1)
      @tm.trust_score.should == 1
    end
    
    it "No, can't change trust diretly" do
      expect { @tm.trust_score = 5 }.to raise_error
    end
  end
  
  context "trust holder can maintain a list" do
    before(:each) do
      @tm = TrustHolderMock.new("Wee")
      @delay_obj = mock "delayed"
    end
              
    it "there are no things" do
      @tm.things.should be_empty
    end
              
    it "add to list, nothing doing until trust horzons" do
      @tm.add_to_list(1, @delay_obj)
      
      @tm.things.should be_empty
      @tm.things.size.should == 0
    end
    
  end

  context "trust holder and trustee can maintain a list and work on it" do
    before(:each) do
      @tm = TrustHolderAndTrusteeMock.new("Woo")
      @delay_obj = mock "delayed"
    end
              
    it "there are no things" do
      @tm.things.should be_empty
    end
              
    it "add to list, nothing doing until trust horzons" do
      @tm.add_to_list(1, @delay_obj)
      
      @tm.things.should be_empty
      @tm.things.size.should == 0
    end
    
    it "add to list, up trust, trust horzons" do
      @tm.add_to_list(1, @delay_obj)
      @tm.trust(1)
      
      @tm.things.should include(@delay_obj)
      @tm.things.size.should == 1
    end
    
  end

end