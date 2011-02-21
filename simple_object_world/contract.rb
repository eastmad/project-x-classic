class Contract
  attr_reader :contract_type, :item, :origin_trader
  attr_accessor :status
  
  @@contract_types = {:sink => "Find a source of", :source => "Find a buyer for"}
  
  def initialize(contract_type, item, origin_trader)
    @status = :available
    @status = :unfulfilled if (contract_type == :sink)
    
    @item = item
    @contract_type = contract_type
    @origin_trader = origin_trader
  end
  
  def to_s
    "#{@@contract_types[@contract_type]} #{@item} (#{@status.to_s})"
  end
  
  def accept
    Consignment.new(@item, @origin_trader)
  end
  
  def fulfill (consignment, contract)
    raise "Only a sink contract can be fulfilled" unless @contract_type == :sink
    raise "Contract already fulfilled" if @status == :fulfilled
    raise "Only a source contract can fulfil a sink" unless contract.contract_type == :source
    raise "Empty consignment" if consignment.amount <= 0
    raise "Wrong consignment" unless consignment.item == @item 
    raise "The consignment orign #{consignment.origin_trader} does not match the contract trader #{contract.origin_trader}" unless contract.origin_trader == consignment.origin_trader

    consignment.amount -= 1
    @status = :fulfilled
    
    contract.origin_trader.trust(1)
    @origin_trader.trust(1)    
  end
end

class Item
  attr_reader :name, :desc, :item_type,:conditions
  
  def initialize(name, desc, item_type, conditions = [])
    @name = name
    @desc = desc
    @item_type = item_type
    @conditions =  conditions.dup
  end
  
  def to_s
    @name
  end
end

class Trade
  attr_reader :state, :con, :trade_type, :item
  
  def initialize(item, trade_type, trader)
    @state = :available
    @trade_type = trade_type
    @item = item
    @con = Consignment.new(item, trader)
  end
end

class Consignment
  attr_reader :item, :origin_trader
  attr_accessor :amount
  
  def initialize(item, origin_trader)
    @origin_trader = origin_trader
    @item = item
    @amount =  1
  end
  
  def to_s
    "#{@amount} units of #{@item.name} (origin: #{@origin_trader})"
  end
end