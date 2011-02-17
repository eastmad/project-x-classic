require "contract.rb"
require "simple_body.rb"
require "simple_game_object.rb"

Shoes.app do
  coffee = Item.new("coffee", "Still a legal stimulent in most markets", :commodity, [:dry])
  gold = Item.new("gold", "Valuable and shiny metal", :rare)
  eye = Item.new("Eye of Horus", "Alien artifact of uknown origin", :unique, [:controlled, :asgaard])
  
  trader1 = TraderMock.new("Bob Sink")
  trader2 = TraderMock.new("Bill Source")
  trader3 = TraderMock.new("Ben Neither")
  trader1.add_sink_contract(coffee)
  trader2.add_source_contract(coffee)
  
  info "sink = #{trader1.contracts.first}"
  info "source = #{trader2.contracts.first}"
  
  consignment_coffee = Consignment.new(coffee, trader1) 
  consignment_gold = Consignment.new(gold, trader3)
  consignment_eye = Consignment.new(eye, trader3)
    
  source_contract = trader2.contracts.first
  sink_contract = trader1.contracts.first
  source_consignment = source_contract.accept
  
  info "source consignment = #{source_consignment}"
  
  
  begin
    sink_contract.fulfill(consignment_coffee, source_contract)
    info "FAIL - consignment not from source"
  rescue => ex
    info "consignment not from source? #{ex}"
  end
  
  begin
    sink_contract.fulfill(consignment_gold, source_contract)
    info "FAIL - wrong item passed"
  rescue => ex
      info "wrong item passed? #{ex}"
  end
  
  sink_contract.fulfill(source_consignment, source_contract)
  
  info "sink contract = #{sink_contract}"
  
  info "source_consignment = #{source_consignment}"
  
  source_consignment.amount += 1
  
  begin
    sink_contract.fulfill(source_consignment, source_contract)
    info "FAIL - already fulfilled"
  rescue => ex
    info "contract already fulfild? #{ex}"
  end
    
end

class TraderMock
  attr_reader :contracts

  def to_s
   "mock trader #{@name}"
  end

  def trust(amount)
   info "#{self} likes you"
  end
  
  def initialize(name)      
    @name = name
    @contracts = []
  end  
  
  def add_sink_contract(item)
    contracts << Contract.new(:sink, item, self)    
  end
  
  def add_source_contract(item)
    contracts << Contract.new(:source, item, self)    
  end
end