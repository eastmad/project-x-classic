class SystemCommunication < ShipSystem 
  Operation.register_sys(:communication)
  def self.cursor_str
      "comms:"
  end
 
  def _contact(args = nil)
    begin
      
      if args.nil?
        city = @@ship.locationPoint.body
        @@rq.enq SystemsMessage.new(city.describe_owns, SystemCommunication, :info) if city.kind_of? City
      else
        sgo = ShipSystem.find_sgo_from_name(args)
    
        @@rq.enq @@ship.contact(sgo)
      end

      {:success => true}
    rescue => ex
      info "oops #{ex}"
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot contact '#{args}'. Check a city's description for known contacts.", SystemCommunication, :response_bad)
      {:success => false}
    end  

  end
  
  def _meet(args = nil)
    begin
      
      if args.nil?
        city = @@ship.locationPoint.body
        @@rq.enq SystemsMessage.new(city.describe_owns, SystemCommunication, :response_bad) if city.kind_of? City
      else
        sgo = ShipSystem.find_sgo_from_name(args)
    
        @@rq.enq @@ship.meet(sgo)
      end

      {:success => true}
    rescue => ex
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot meet '#{args}'. Check a city's description for known contacts.", SystemCommunication, :response_bad)
      {:success => false}
    end  

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
