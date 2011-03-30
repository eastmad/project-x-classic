require "./trade.rb"
require "./simple_body.rb"
require "./trust_holder.rb"
require "./trustee.rb"
require "./trader.rb"
require "./simple_game_object.rb"
require "../control_systems/system_test_helper"
include TestHelper

class TraderMock < Trader
  
  def initialize(name)
    @name = name
    @index_name = "Poo"
    @trades = []
    @owning_body = "Jupiter"
  end

  def to_s
   "mock trader #{@name}"
  end
  
end

describe Trade do

  before(:each) do
    @coffee = Item.new("coffee", "Still a legal stimulent in most markets", :commodity, [:dry])
    @gold = Item.new("gold", "Valuable and shiny metal", :rare)
    @eye = Item.new("Eye of Horus", "Alien artifact of uknown origin", :unique, [:controlled, :asgaard])
  
    @trader1 = TraderMock.new("Bob Sink")
    @trader2 = TraderMock.new("Bill Source")
    @trader3 = TraderMock.new("Ben Neither")
    @trader1.add_sink_trade(@coffee)
    @trader2.add_source_trade(@coffee)
    @trader2.add_source_trade(@eye,1)
    
    @consignment_coffee = Consignment.new(@coffee, @trader1) 
    @consignment_gold = Consignment.new(@gold, @trader3)
    @consignment_eye = Consignment.new(@eye, @trader3)
      
    @source_trade = @trader2.trades.first
    @sink_trade = @trader1.trades.first
  end
  
  it "should be able to accept" do
    source_consignment = @source_trade.accept
    source_consignment.item.should == @coffee
  end
  
  it "can't fulfill with wrong item" do
    expect { @sink_trade.fulfill(@consignment_gold) }.to raise_error(RuntimeError, "Wrong item")
  end
  
  it "should be 1 trade" do
    @trader2.trades.count.should == 1
  end
  
  context "after a fulfill" do
  
    before(:each) do
      @source_consignment = @source_trade.accept
      @sink_trade.fulfill(@source_consignment)
    end
  
    it "should increment trades as we get hidden trade" do
      @trader2.trades.count.should == 2
    end
    
    it "should increase trust in both traders" do
      @trader2.trust_score.should == 1
      @trader1.trust_score.should == 1
      @trader3.trust_score.should == 0
    end 
   
    it "should get a message" do
      @trader2.trades.count.should == 2
      txt = SimpleBody.get_mail.last.txt
      txt.should include("Eye of Horus")
      txt.should include("Jupiter")
    end
  
    it "cannot fulfill a fulfilled trade" do
      expect { @sink_trade.fulfill(@source_consignment) }.to raise_error(RuntimeError, "Trade already fulfilled")
    end
  end
end  
  
