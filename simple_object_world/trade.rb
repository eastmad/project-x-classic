class Trade
  attr_reader :trade_type, :item, :origin_trader
  attr_accessor :status
  
  @@trade_types = {:sink => "Need ", :source => "Supplying"}
  
  def initialize(item, trade_type, origin_trader)
    @status = :available
    @status = :unfulfilled if (trade_type == :sink)
    
    @item = item
    @trade_type = trade_type
    @origin_trader = origin_trader
  end
  
  def to_s
    "#{@@trade_types[@trade_type]} #{@item} (#{@status.to_s})"
  end
  
  def accept
    Consignment.new(@item, @origin_trader)
  end
  
  def fulfill (consignment)
    raise "Only a sink trade can be fulfilled" unless @trade_type == :sink
    raise "Trade already fulfilled" if @status == :fulfilled
    raise "Empty consignment" if consignment.amount <= 0
    raise "Wrong item" unless consignment.item == @item 

    consignment.amount -= 1
    @status = :fulfilled
    
    consignment.origin_trader.trust(1)
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