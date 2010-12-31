class Trader < SimpleBody
  attr_reader :tradePoint, :index_name
  attr_accessor :contracts
  
  def initialize(name, index, desc, ownerPoint)      
    super(name, desc, ownerPoint.body) 
    @index_name = index
    ownerPoint.add_link([:trader], LocationPoint.new(self, :centre)) 
    @contracts = []
  end      

  def describe
  "#{@name} (#{@index_name}) is a trader in space port #{@owning_body.name}"
  end

  def describe_owns
    ret = "No contracts"
    ret = "Contracts:\n #{contracts.join('\n ')}" unless contracts.empty? 
    ret
  end

  def to_s
   "#{@name} (#{@index_name})"
  end
end