require "contract.rb"
require "simple_body.rb"
require "simple_game_object.rb"
require "../control_systems/system_test_helper"
include TestHelper

class TraderMock
  attr_reader :contracts
  attr_reader :trades
  
  def initialize(name)      
    @trust_score = 0
    @name = name
    @contracts = []
    @trades = []
    @trust_list = []
  end

  def to_s
   "mock trader #{@name}"
  end

  def trust(amount)
    puts "#{self} likes you"
    @trust_score += amount
    check_trust_bucket
  end
  
  
  def delay trust_needed, trade
    @trust_list << {:trust => trust_needed, :trade => trade}
  end
  
  def add_sink_contract(item)
    contracts << Contract.new(:sink, item, self)    
  end
  
  def add_source_contract(item)
    contracts << Contract.new(:source, item, self)    
  end
  
  private
  
  def check_trust_bucket
    @trust_list.each do | t |
      if t[:trust] <= @trust_score
        @trades << t[:trade]
      end
    end
  end
end

describe Contract do
end

  coffee = Item.new("coffee", "Still a legal stimulent in most markets", :commodity, [:dry])
  gold = Item.new("gold", "Valuable and shiny metal", :rare)
  eye = Item.new("Eye of Horus", "Alien artifact of uknown origin", :unique, [:controlled, :asgaard])
  
  trader1 = TraderMock.new("Bob Sink")
  trader2 = TraderMock.new("Bill Source")
  trader3 = TraderMock.new("Ben Neither")
  trader1.add_sink_contract(coffee)
  trader2.add_source_contract(coffee)
  trade = Trade.new(eye, :give, trader2)
  trader2.delay(1, trade)
  
  puts "sink = #{trader1.contracts.first}"
  puts "source = #{trader2.contracts.first}"
  
  consignment_coffee = Consignment.new(coffee, trader1) 
  consignment_gold = Consignment.new(gold, trader3)
  consignment_eye = Consignment.new(eye, trader3)
    
  source_contract = trader2.contracts.first
  sink_contract = trader1.contracts.first
  source_consignment = source_contract.accept
  
  puts "source consignment = #{source_consignment}"
  
  begin
    sink_contract.fulfill(consignment_coffee, source_contract)
    puts "FAIL - consignment not from source"
  rescue => ex
    puts "consignment not from source? #{ex}"
  end
  
  begin
    sink_contract.fulfill(consignment_gold, source_contract)
    puts "FAIL - wrong item passed"
  rescue => ex
      puts "wrong item passed? #{ex}"
  end
  
  puts "Trades should be empty? #{trader2.trades.count}"
  
  sink_contract.fulfill(source_consignment, source_contract)
  
  puts "Trades should be 1? #{trader2.trades.count}"  

  puts "sink contract = #{sink_contract}"
  
  puts "source_consignment = #{source_consignment}"
  
  source_consignment.amount += 1
  
  
  begin
    sink_contract.fulfill(source_consignment, source_contract)
    puts "FAIL - already fulfilled"
  rescue => ex
    puts "contract already fulfild? #{ex}"
  end
    
  
