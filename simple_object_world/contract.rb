class Contract
  attr_reader :contract_type, :item, :status   
  
  @@contract_types = {:sink => "Find a source of", :source => "Find a buyer for"}
  
  def initialize(contract_type, item)
    @status = :available
    @item = item
    @contract_type = contract_type
  end
  
  def to_s
    "#{@@contract_types[@contract_type]} #{@item} (#{@status.to_s})"
  end
end

class Item
  attr_reader :name, :desc, :item_type, :conditions
  
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