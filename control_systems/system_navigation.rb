class SystemNavigation < ShipSystem
    
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
        resp_hash = {:str => ret, :success => true, :media => :travel}
        @@rq.enq SystemsMessage.new(ret, SystemNavigation, :response)
     rescue RuntimeError => ex 
       resp_hash = {:str => ex, :success => false}
       @@rq.enq ex
       @@rq.enq SystemsMessage.new("Cannot plot course", SystemNavigation, :response_bad)
     end      
       
     return resp_hash  
  end
  
  
  def _dock(args = nil)     
     #info "Call dock"
     begin
       sgo = find_sgo_from_name(@obj)     
       @@ship.dock sgo
       ret = "#{@@ship.name} docked"      
       if (!sgo.nil?)
             ret += " to #{@obj}"
       end
       resp_hash = {:str => ret, :success => true, :media => :docking}
       @@rq.enq SystemsMessage.new(ret, SystemNavigation, :response)
     rescue RuntimeError => ex      
       resp_hash = {:str => ex, :success => false}
       @@rq.enq ex
       @@rq.enq SystemsMessage.new("Cannot dock", SystemNavigation, :response)
     end      
       
     return resp_hash
  end
  
  def initialize
  end
   
  def to_s
      "I am the navigation system"
  end
  
  def self.cursor_str
      "Nav"
  end
end
