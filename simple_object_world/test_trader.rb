require_relative "trust_holder"
require_relative "trustee"
require_relative "location_point"
require_relative "simple_body"
require_relative "contact"
require_relative "trader"
require_relative "trade"
require_relative "../control_systems/system_test_helper"
include TestHelper

describe Trader do

  before(:each) do
    @link = mock "link"
    @body = mock "body"
    @ownerPoint = mock "locpoint", :body => @body, :add_link => @link
    @trader = Trader.new("poo", :Trading, "Miner's Union run station", @ownerPoint)
  end
  
  context "for org" do
    before :each do
      @org = mock "org", :name => "MyOrg", :kind_of? => :true
      @trader.set_owning_org @org
    end
    
    it "should have the right org" do
       @trader.owning_org.should == @org
    end
    
    it "should have no trades" do
      @trader.trades.should be_empty      
    end
    
    context "add trades" do
      before :each do
        @org = mock "org", :name => "MyOrg", :kind_of? => :true, :trust_score => 0
        @item1 = mock "item"
        @item2 = mock "item2", :item_type => :unique, :name => "name"
        @trader.set_owning_org @org
        @trader.add_sink_trade(@item1)
        @trader.add_source_trade(@item2,1)
      end
      
      it "should only have 1 trade" do
        @org.should_receive(:trust_score).and_return(0)
        @trader.trades.size.should == 1
      end
      
      it "if trust increases, should have 2 trade" do        
        @org.should_receive(:trust_score).and_return(1)
        @trader.trades.size.should == 2
      end

    end
  end
  
  context "for no org" do
    
    it "should have the right org" do
       @trader.owning_org.should == @trader
    end
    
    it "should have no trades" do
      @trader.trades.should be_empty      
    end
    
    context "add trades" do
      before :each do
        @item1 = mock "item"
        @item2 = mock "item"
        @trader.add_sink_trade(@item1)
        @trader.add_sink_trade(@item2,1)
      end
      
      it "should only have 1 trade" do
        @trader.trades.size.should == 1
      end
      
      it "if trust increases, should have 2 trade" do        
        @trader.trust(1)
        @trader.trades.size.should == 2
      end
    end   
  end
  
end