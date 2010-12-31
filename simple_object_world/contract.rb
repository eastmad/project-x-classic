class Contract
  attr_reader :contract_type, :item, :status   
  
  @@contract_types = {:supply => "Find a source of"}
  
  def initialize(contract_type, item, trader)
    @status = :Available
    @item = item
    @contract_type = contract_type
    trader.contracts << self
  end
  
  def to_s
    "#{@@contract_types[@contract_type]} #{@item} (#{@status.to_s})"
  end
end

class Item
  attr_reader :name
  
  def initialize(name)
    @name = name
  end
  
  def to_s
    @name
  end
end