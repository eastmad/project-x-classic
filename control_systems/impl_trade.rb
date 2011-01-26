class ImplTrade
  attr_reader :contracts, :cargo 
   
  def initialize
    @contracts = [] 
    @cargo = [] 
  end
  
  def source_offered (station, item)
    traders = station.centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    traders.each do | trader | 
      trader.contracts.each { |contract| return contract if contract.item == item and contract.contract_type == :source}
    end 
    
    nil
  end
  
  def sink_offered (station, item)
  info "sink offered #{item}"
    traders = station.centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
info "traders =  #{traders.count}"
    traders.each do | trader | 
      trader.contracts.each do |contract| 
        info "sink_offered #{contract.item} == #{item} #{:sink} == #{contract.contract_type}"
        return contract if contract.item == item and contract.contract_type == :sink
       end
    end 
info "sink_offered nil"
    nil
  end
  
  def find_consignment(item)
    @cargo.each do | consignment |
    info "consignment #{consignment.item} == #{item}"
      return consignment if consignment.item == item
    end
  end
  
  def find_contract(type, item)
    @contracts.each do | contract |
      info "contract #{contract.item} == #{item} #{contract.contract_type } == #{type}"
      return contract if contract.item == item and contract.contract_type == type
    end
  end

end

