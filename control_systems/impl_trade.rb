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

end

