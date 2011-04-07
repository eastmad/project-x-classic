class SystemNavigation < ShipSystem
    
  Operation.register_sys(:navigation)
    
  def _probe(args = nil)
    @subj = "probe"
  end
    
  def _planet(args = nil)
    @obj = "planet"
  end
  
  def _nearest(args = nil)
    @adj = "nearest"
  end
   
  def _course(arg = nil)        
  end    
  
  def _plot(args = nil)     
    begin        
      sgo = ShipSystem.find_sgo_from_name(@obj)          
      if (!sgo.nil?)
         @@rq.enq @@ship.set_heading sgo
      else
        raise SystemsMessage.new("No planet to plot a course to.", SystemNavigation, :info)
      end
      resp_hash = {:success => true, :media => :plot_course}
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot plot course", SystemNavigation, :response_bad)
    end      
      
    return resp_hash  
  end
  
  def _orbit(args = nil)     
    #info "Call orbit"
    begin      
      sgo = ShipSystem.find_sgo_from_name(args)
      if sgo.nil?
        lp = @@ship.locationPoint.find_linked_location :orbit
        sgo = lp.first.body unless lp.empty?
      end  
      @@rq.enq @@ship.orbit sgo
      resp_hash = {:success => true, :media => :orbit}
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Establish orbit after launching from station or planet.", SystemNavigation, :response_bad)
    end      
         
    return resp_hash  
  end

  def self.to_s
      "navigation system"
  end
  
  def self.status
    @@rq.enq SystemsMessage.new("#{@@ship.name} is #{@@ship.describeLocation}", SystemNavigation, :info)
  end
  
  def self.cursor_str
      "nav:"
  end
 
end
