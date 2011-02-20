class SystemCommunication < ShipSystem 
  Operation.register_sys(:communication)
  def self.cursor_str
      "comms:"
  end
  
  def _read(args = nil)
    begin
      
      mail = @@ship.read_mail
           
      @@rq.enq SystemsMessage.new(mail.txt, SystemCommunication, :mail)
    
      {:success => true}
    rescue => ex
      info "Ooh dear #{ex}"
      @@rq.enq SystemsMessage.new("No mail.", SystemCommunication, :response_bad)
      {:success => false}
    end
  end
  
  def _mail(args = nil)
    return SystemGhost.welcome
  end
 end
