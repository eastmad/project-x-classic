class ImplTrade
  attr_accessor :cargo 
   
  def initialize
    @cargo = [] 
  end
  
  def manifest
    
    para1 = ""
    ind = 1;
    @cargo.each do |con|
      para1 << "Bay #{ind}: #{con.to_s}\n"
      ind += 1
    end
  
    para1
  end
  
  def bay n
    
    ind = n - 1
    con = @cargo[ind]
    return "" if con.nil?
            
    para1 = "#{con.to_s}\n"
    para1 << "#{con.item.desc}\n"
    para1 << "#{con.item.notes}\n"
    
    para1
  end
  
  def source_offered (station, item)
    traders = station.centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    traders.each do | trader | 
      trader.trades.each { |trade| return trade if trade.item == item and trade.trade_type == :source}
    end 
    
    nil
  end
  
  def sink_offered (station, item)
    traders = station.centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    traders.each do | trader | 
      trader.trades.each do |trade| 
        return trade if trade.item == item and trade.trade_type == :sink
       end
    end 
    nil
  end
  
  def find_consignment(item)
    @cargo.each do | consignment |
      return consignment if consignment.item == item
    end
  end
  
  def find_trade(type, item)
    @trades.each do | trade |
      return trade if trade.item == item and trade.trade_type == type
    end

    nil    
  end

end

