class SystemCommunication < ShipSystem 
  Operation.register_sys(:communication)
  def self.cursor_str
      "comms:"
  end
  
  def _read(args = nil)
    begin
      
      mail = @@ship.read_mail args
      
      txt = mail.txt || "No new mail"
           
      @@rq.enq SystemsMessage.new(txt, mail.from, :mail) 
    
      {:success => true}
    rescue => ex
      info "Ooh dear #{ex}"
      @@rq.enq SystemsMessage.new("No mail.", SystemCommunication, :response_bad)
      {:success => false}
    end
  end
  
  def _mail(args = nil)
    {:position => :last}
  end
  
  def _last(args = nil)
    {:position => :last}
  end
  
  def _first(args = nil)
    {:position => :first}
  end
  
  def _previous(args = nil)
    {:direction => :prev}
  end
  
  def _next(args = nil)
    {:direction => :prev}
  end
  
 end
