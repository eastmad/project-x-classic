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
  
  def to_s
    "Trade"
  end
end