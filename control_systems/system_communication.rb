class SystemCommunication < ShipSystem 
  Operation.register_sys(:communication)
  def self.cursor_str
      "comms:"
  end
  
  def _read(args = nil)
    begin
      
      mes = args
      mes = SystemGhost.welcome if args.nil?      
      
      @@rq.enq mes
    
      {:success => true}
    rescue
      @@rq.enq SystemsMessage.new("No mail.", SystemCommunication, :response_bad)
      {:success => false}
    end
  end
  
  def _mail(args = nil)
    return SystemGhost.welcome
  end
  
  def _page(args = nil)
    return SystemTrade.welcome
  end
end
