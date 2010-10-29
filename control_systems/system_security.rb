class SystemSecurity < ShipSystem 
  Operation.register_sys(:security)
  def _undock(args = nil)     
    #info "Call undock"
    begin
      @@ship.undock
      ret = "#{@@ship.name} docking clamps released"
      if (!@obj.nil?)
         ret += " from #{@obj}"
      end
      resp_hash = {:success => true}
      @@rq.enq SystemsMessage.new(ret, SystemPower, :response)
    rescue RuntimeError => ex 
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot release clamps", SystemSecurity, :response)
    end      
       
    return resp_hash  
  end
  
  def self.cursor_str
      "Sec"
  end
end
