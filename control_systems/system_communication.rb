class SystemCommunication < ShipSystem 
  Operation.register_sys(:communication)
  def self.cursor_str
      "comms:"
  end
  
  def _view(args = nil)
    
    sgo = ShipSystem.find_sgo_from_name(@obj) unless @obj.nil?
    
    #default to contacts in current city
    sgo = @@ship.locationPoint.body.root_body if sgo.nil? 
    para1 = ""
    if sgo.kind_of? City or sgo.kind_of? Planet  
      para1 = sgo.describe_contacts
    else
      planets = sgo.owns.collect{|locPoint| locPoint.body}
      planets.each {|planet| para1 << planet.describe_contacts}
    end
    
    if para1.empty?
      @@rq.enq SystemsMessage.new("No known contacts", SystemCommunication, :info)
    else
      para1 << "\n\nType 'contact person' to arrange a meeting"
      @@rq.enq SystemsMessage.new("Contacts\n\n#{para1}", SystemCommunication, :report)
    end
    {:success => true}
  end
 
  def _contact(args = nil)
    begin
      
      raise SystemsMessage.new("Contact who?", SystemCommunication, :response_bad) if args.nil?
      
      sgo = ShipSystem.find_sgo_from_name(args)
    
      @@rq.enq @@ship.contact(sgo)
      
      {:success => true}
    rescue => ex
      info "oops #{ex}"
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Type 'view contacts' for known contacts.", SystemCommunication, :info)
      {:success => false}
    end  
  end
  
  def _meet(args = nil)
    begin
      
      raise SystemsMessage.new("Meet who?", SystemCommunication, :response_bad) if args.nil?
      
      sgo = ShipSystem.find_sgo_from_name(args)
    
      @@rq.enq @@ship.meet(sgo)
      talk = sgo.details[:talk]

      {:success => true, :talk => talk}
    rescue => ex
      info "oops #{ex}"
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Type 'view contacts' for known contacts.", SystemCommunication, :info)
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
  
  def self.status
    a = @@ship
    info "1"
    b = a.icontact
    info "2"
    c = b.contacts
    info "3"
    para1 = "  - #{c.size} contacts known"
    para1 << "  - #{@@ship.mail.mails.size} messages"
  end
  
  def self.to_s
      "Communication system"
  end
  
  def self.cursor_str
      "comms:"
  end
 end
