class SystemTrade < ShipSystem 
  #Operation.register_sys(:trade)  
  attr_accessor :trade_page

  def self.cursor_str
    "trade:"
  end
  
  def self.welcome
  
    para1 = <<-END.gsub(/^ {8}/, '')
        #{@trade_page}
    END
    
    SystemsMessage.new(para1, SystemTrade, :mail)
  end  
  
  def self.prepare_trade_page(station)
    @trade_page = station.trade_page  
  end
  
  def _accept(args = nil)
    begin    
      @@rq.enq SystemsMessage.new("Consignment of #{@obj} taken aboard", SystemTrade, :response_good)
      {:success => true}
    rescue
      @@rq.enq SystemsMessage.new("Cannot accept.", SystemTrade, :response_bad)
      {:success => false}
    end
  end
  
  def to_s
    "Trade"
  end
end