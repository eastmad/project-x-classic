class Contract
  attr_reader :contract_type, :item, :origin_body
  attr_accessor :status
  
  @@contract_types = {:sink => "Find a source of", :source => "Find a buyer for"}
  
  def initialize(contract_type, item, origin_body = nil)
    @status = :available
    @status = :unfulfilled if (contract_type == :sink)
    
    @item = item
    @contract_type = contract_type
    @origin_body = origin_body
  end
  
  def to_s
    "#{@@contract_types[@contract_type]} #{@item} (#{@status.to_s})"
  end
  
  def accept
    Consignment.new(@item, @origin_body)
  end
  
  def fulfil (consignment, contract)
    raise "Only a sink contract can be fulfilled" unless @contract_type == :sink
    raise "Contract already fulfilled" if @status == :fulfilled
    raise "Only a source contract can fulfil a sink" unless contract.contract_type == :source
    raise "Empty consignment" if consignment.amount <= 0
    raise "Wrong consignment" unless consignment.item == @item 
    raise "The consignment orign #{consignment.origin_body} does not match the contract" unless contract.origin_body == consignment.origin_body

    consignment.amount -= 1
    @status = :fulfilled
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
  attr_reader :item, :origin_body
  attr_accessor :amount
  
  def initialize(item, origin_body)
    @origin_body = origin_body
    @item = item
    @amount =  1
  end
  
  def to_s
    "#{@amount} units of #{@item.name} (origin: #{@origin_body})"
  end
end