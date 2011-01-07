class SystemCommunication < ShipSystem 
  Operation.register_sys(:communication)
  def self.cursor_str
      "comms:"
  end
  
  def _read(args = nil)
    begin
 	    @@rq.enq SystemGhost.welcome
    
      {:success => true}
    rescue
      @@rq.enq SystemsMessage.new("No mail.", SystemCommunication, :response_bad)
      {:success => false}
    end
  end
end
