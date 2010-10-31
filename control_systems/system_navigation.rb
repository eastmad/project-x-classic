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
    rbody = @@ship.locationPoint.body.root_body
    planets = rbody.owns.collect{|locPoint| locPoint.body}
    para1 = <<-END.gsub(/^ {6}/, '')
      We are in the #{rbody} system.
      The orbiting planets are #{planets.join(", ")}.
      
      Type 'describe Mars' to find information about one celestial body
    END
    @@rq.enq SystemsMessage.new(para1, SystemNavigation, :response)
    {:success => true, :media => :docking}
  end
  
  def _compute(arg = nil)
    {:str => "Poo\nPoo\nPoo\nPoo\nPoo", :success => true, :media => :travel}
  end
  
  def _plot(args = nil)     
    info "Call plot"
    begin        
      sgo = ShipSystem.find_sgo_from_name(@obj)          
      if (!sgo.nil?)
        ret = "Course plotted to #{@obj}"
        @@ship.set_heading sgo
      end
      resp_hash = {:str => ret, :success => true, :media => :plot_course}
      @@rq.enq SystemsMessage.new(ret, SystemNavigation, :response)
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot plot course", SystemNavigation, :response_bad)
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
