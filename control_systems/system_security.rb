class SystemSecurity < ShipSystem 

  def _undock(args = nil)     
    #info "Call undock"
    begin
      @@ship.undock
      ret = "#{@@ship.name} undocked"
      if (!@obj.nil?)
         ret += " from #{@obj}"
      end
      resp_hash = {:str => ret, :success => true, :media => :travel}
      @@rq.enq SystemsMessage.new(ret, SystemPower, :response)
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot release clamps", SystemSecurity, :response)
    end      
       
    return resp_hash  
  end
  
  def self.cursor_str
      "Sec"
  end
end