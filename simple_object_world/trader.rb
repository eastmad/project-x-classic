class Trader < SimpleBody
  attr_reader :tradePoint, :index_name, :trades
  include TrustHolder
  include Trustee
  
  def initialize(name, index, desc, ownerPoint)      
    super(name, desc, ownerPoint.body) 
    @index_name = index
    ownerPoint.add_link([:trader], LocationPoint.new(self, :centre)) 
    @trades = []
  end
 
  def trades
    check_trust_list
    @trades
  end
 
  def add_sink_trade(item, trust = 0)
    trade = Trade.new(item, :sink, self)
    add_trade trade, trust
  end
  
  def add_source_trade(item, trust = 0)
    trade = Trade.new(item, :source, self)
    add_trade trade, trust
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

  def horizon trust, trade
    if trust <= trust_score
      @trades << trade
      info "#{trade.item} added to trades"
      push_message thanks(trade), to_s
      return true
    end
    
    false
  end
  
  def add_trade trade, trust
    add_to_trust_list trust, trade
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