class Trader < SimpleBody
  attr_reader :tradePoint, :index_name, :trades, :trust_score
  
  def initialize(name, index, desc, ownerPoint)      
    super(name, desc, ownerPoint.body) 
    @index_name = index
    ownerPoint.add_link([:trader], LocationPoint.new(self, :centre)) 
    @trades = []
    @trust_list = []
    @trust_score = 0
  end
  
  def trust(amount)
    info "trust change #{amount} for #{to_s}"
    @trust_score += amount
    check_trust_bucket
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
  
  def add_trade trade, trust
    if trust <= @trust_score
      @trades << trade
    else  
      @trust_list << {:trust => trust, :trade => trade}
    end 
  end
  
  def check_trust_bucket
    @trust_list.each do | t |
      if t[:trust] <= @trust_score
        trade = t[:trade]
        @trades << trade
        info "#{trade.item} added to trades"
        push_message thanks(trade), to_s
        t[:trust] = 1000
      end
    end
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