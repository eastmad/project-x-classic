class ImplTrade
  attr_accessor :cargo, :max_bays
  
  Bay_colour_map = {"red" => 0, "orange" => 1, "yellow" => 2, "green" => 3, "blue" => 4, "indigo" => 5, "violet" => 6}
   
  def initialize max = 6
    @cargo = []
    @max_bays = max
  end
  
  def manifest
    
    para1 = "  Cargo bay manifest\n\n"
    ind = 0;
    Bay_colour_map.each do |key, value|
      con = @cargo[value]
      para1 << "  #{key} bay: #{con.to_s}\n" unless con.nil?
      ind += 1
    end
  
    para1
  end
  
  def bay colour
    
    ind = Bay_colour_map[colour]
    con = @cargo[ind]
    return "" if con.nil?
            
    para1 = "  #{con.item.name} (bay #{colour})\n\n"
    para1 << "  #{con.item.desc}\n"
    para1 << "  #{con.item.notes}\n"
    
    para1
  end
  
  def source_offered (station, item)
    traders = station.centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    traders.each do | trader | 
      trader.trades.each { |trade| return trade if trade.item == item and trade.trade_type == :source and trade.status == :available}
    end 
    
    nil
  end
  
  def service_module_offered (station, type)
    garages = station.centrePoint.find_linked_location(:garage).collect{|traderPoint| traderPoint.body}
    garages.each do | garage |
      garage.services.each { |service| return service if service.type == type}
    end 
    
    nil
  end
  
  def sink_offered (station, item)
    traders = station.centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    traders.each do | trader | 
      trader.trades.each do |trade| 
        return trade if trade.item == item and trade.trade_type == :sink and trade.status == :unfulfilled
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
      return trade if trade.item == item and trade.trade_type == type and trade.status == :available
    end

    nil    
  end

end

