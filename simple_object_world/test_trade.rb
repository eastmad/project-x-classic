require "contract.rb"
require "simple_body.rb"
require "trader.rb"
require "simple_game_object.rb"
require "../control_systems/system_test_helper"
include TestHelper

class TraderMock < Trader
  attr_reader :contracts
  attr_reader :consignments
  
  def initialize(name)
    @name = name
    @index_name = "Poo"
    @contracts = []
    @consignments = []
    @trust_list = []
    @trust_score = 0
  end

  def to_s
   "mock trader #{@name}"
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
  
  puts "Trades should be empty? #{trader2.consignments.count}"
  
  sink_contract.fulfill(source_consignment, source_contract)
  
  puts "Trades should be 1? #{trader2.consignments.count}"  

  puts "sink contract = #{sink_contract}"
  
  puts "source_consignment = #{source_consignment}"
  
  source_consignment.amount += 1
  
  
  begin
    sink_contract.fulfill(source_consignment, source_contract)
    puts "FAIL - already fulfilled"
  rescue => ex
    puts "contract already fulfild? #{ex}"
  end
    
  
