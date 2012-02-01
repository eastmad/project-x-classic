class Trader < SimpleBody
  attr_reader :tradePoint, :index_name, :trades, :owning_org
  include TrustHolder
  include Trustee
  
  def initialize(name, index, desc, ownerPoint, id = nil )   
    super(name, desc, ownerPoint.body, id) 
    @index_name = index    
    ownerPoint.add_link([:trader], LocationPoint.new(self, :centre)) 
    @trades = []
    @owning_org = self
  end
  
  def set_owning_org org
    raise "Attempting to set non org for trader" unless org.kind_of? Organisation
    @owning_org = org
  end
 
  def trades
    check_trust_list
    info "trades number = #{@trades.size}"
    @trades
  end
 
  def add_sink_trade(item, trust = 0)
    trade = Trade.new(item, :sink, self)
    add_trade trade, trust, @owning_org
  end
  
  def add_source_trade(item, trust = 0)
    trade = Trade.new(item, :source, self)
    add_trade trade, trust, @owning_org
  end
    
  def describe
    "#{to_s} is a trader in space port #{@owning_body.name}"
  end

  def describe_owns
    ret = "No Trades"
    ret = "Trades:\n #{trades.join('\n ')}" unless trades.empty? 
    ret
  end
  
  def to_s
   "#{@name} #{@index_name}"
  end
  
  private

  def horizon trust, trade, trustee
    if trust <= trustee.trust_score
      @trades << trade
      info "#{trade.item} added to trades trust = #{trust} type=#{trade.trade_type} for #{self}"
      push_message(thanks(trade), to_s) if trust > 0 and trade.trade_type == :source 
      return true
    end
    
    false
  end
  
  def add_trade trade, trust, org
    info "adding #{trade} to trust list of #{self} with trust=#{trust}, and org = #{org}"
    add_to_trust_list trust, trade, org
  end
  
  def thanks trade
    
    desc = "a unique '#{trade.item.name}'" if trade.item.item_type == :unique
    desc = "a consignment of '#{trade.item.name}'" if trade.item.item_type == :rare
    
    para1 = <<-END.gsub(/^ {8}/, '')
        Customer,
        
         Thank you for previous business.
        You may be interested in taking from us 
        #{desc}
        which we will make available at 
        #{trade.origin_trader.owning_body}      
    END
    
    para1
  end
end

class Garage < SimpleBody
  attr_reader :tradePoint, :index_name, :services, :owning_org
  include TrustHolder
  include Trustee
  
  def initialize(name, index, desc, ownerPoint, id = nil)      
    super(name, desc, ownerPoint.body, id) 
    @index_name = index
    ownerPoint.add_link([:garage], LocationPoint.new(self, :centre))
    @services = []
    @owning_org = self
  end
  
  def set_owning_org org
    raise "Attempting to set non org for garage" unless org.kind_of? Organisation
    @owning_org = org
  end
  
  def services
    check_trust_list
    @services
  end

  #we will assume a torpedo for now
  def add_service_module mod_class, trust = 0
    add_service mod_class, trust, @owning_org
  end
     
  def describe
    "#{to_s} is a service garage in satellite #{@owning_body.name}"
  end

  def describe_owns
    ret = "No services"
    ret = "Services:\n #{@services.join('\n ')}" unless services.empty? 
    ret
  end
  
  def to_s
   "#{@name} #{@index_name}"
  end
  
  private

  def horizon trust, mod_class, trustee
    if trust <= trustee.trust_score
      @services << mod_class
      info "#{mod_class.name} added to service trust = #{trust} type=#{mod_class.type}"
      #push_message(thanks(trade), to_s) if trust > 0 and trade.trade_type == :source 
      return true
    end
    
    false
  end
  
  def add_service mod, trust, org
    add_to_trust_list trust, mod, org
  end
  
end