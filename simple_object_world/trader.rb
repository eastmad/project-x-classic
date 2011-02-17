class Trader < SimpleBody
  attr_reader :tradePoint, :index_name, :contracts
  
  def initialize(name, index, desc, ownerPoint)      
    super(name, desc, ownerPoint.body) 
    @index_name = index
    ownerPoint.add_link([:trader], LocationPoint.new(self, :centre)) 
    @contracts = []
  end      

  def add_sink_contract(item)
    contracts << Contract.new(:sink, item, self)    
  end
  
  def add_source_contract(item)
    contracts << Contract.new(:source, item, self)    
  end
  
  def trust(amount)
    info "trust change #{amount} for #{to_s}"
  end
  
  def describe
    "#{to_s} is a trader in space port #{@owning_body.name}"
  end

  def describe_owns
    ret = "No contracts"
    ret = "Contracts:\n #{contracts.join('\n ')}" unless contracts.empty? 
    ret
  end

  def to_s
   "#{@name} #{@index_name}"
  end
end