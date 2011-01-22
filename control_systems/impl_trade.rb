class ImplTrade
  attr_reader :contracts 
   
  def initialize
    @contracts = [] 
  end
  
  def source_offered? (station, item)
    true
  end

end

