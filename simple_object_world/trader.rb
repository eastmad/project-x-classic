class Trader < SimpleBody
  attr_reader :tradePoint, :index_name, :contracts, :consignments
  
  def initialize(name, index, desc, ownerPoint)      
    super(name, desc, ownerPoint.body) 
    @index_name = index
    ownerPoint.add_link([:trader], LocationPoint.new(self, :centre)) 
    @contracts = []
    @consignments = []
    @trust_list = []
    @trust_score = 0
  end
  
  def trust(amount)
    info "trust change #{amount} for #{to_s}"
    @trust_score += amount
    check_trust_bucket
  end

  def add_sink_contract(item)
    contracts << Contract.new(:sink, item, self)    
  end
  
  def add_source_contract(item)
    contracts << Contract.new(:source, item, self)    
  end
  
  def delay trust_needed, trade
    @trust_list << {:trust => trust_needed, :trade => trade}
  end
   
  def describe
    "#{to_s} is a trader in space port #{@owning_body.name}"
  end

  def describe_owns
    ret = "No contracts"
    ret = "Contracts:\n #{contracts.join('\n ')}" unless contracts.empty? 
    ret
  end
  
  private
  
  def check_trust_bucket
    @trust_list.each do | t |
      if t[:trust] <= @trust_score
        @consignments << t[:trade]
        info "#{t[:trade]} added to consignments"
      end
    end
  end

  def to_s
   "#{@name} #{@index_name}"
  end
end