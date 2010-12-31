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
  
  def _describe(arg = nil)
    begin
      sgo = ShipSystem.find_sgo_from_name(@obj)
       
      sgo = @@ship.locationPoint.body.root_body if (@obj.nil?)
      
      para1 = sgo.describe
      para1 << "\n- " << sgo.desc
      para1 << "\n- " << sgo.describe_owns
      para1 << "\nType 'describe Mars' to find information about one celestial body" if @obj.nil?

      @@rq.enq SystemsMessage.new(para1, SystemNavigation, :response)
      {:success => true, :media => :describe}
    rescue RuntimeError => ex
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemNavigation, :response_bad)
    end
  end
  
  def _compute(arg = nil)
    {:str => "Poo\nPoo\nPoo\nPoo\nPoo", :success => true, :media => :travel}
  end
  
  def _plot(args = nil)     
    begin        
      sgo = ShipSystem.find_sgo_from_name(@obj)          
      if (!sgo.nil?)
         @@rq.enq @@ship.set_heading sgo
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
      sgo = ShipSystem.find_sgo_from_name(@obj)     
      @@rq.enq @@ship.orbit sgo
      resp_hash = {:success => true, :media => :orbit}
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot enter orbit", SystemNavigation, :response_bad)
    end      
         
    return resp_hash  
  end

  def to_s
      "I am the navigation system"
  end
  
  def self.status
    @@rq.enq SystemsMessage.new("#{@@ship.name} is #{@@ship.describeLocation}", SystemNavigation, :info)
  end
  
  def self.cursor_str
      "Nav"
  end
end
