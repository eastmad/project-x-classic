class SystemPower < ShipSystem
      
  def _launch(args=nil)
    
    begin
      if (args.nil?)
         ret = "#{@@ship.name} launched"   
      else
        ret = "#{@subj} launched towards #{@adj} #{@obj}"   
      end       
      resp_hash = {:str => ret, :success => true, :media => :travel}
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
    end      
              
    return resp_hash 
    
  end   

  def _probe(args = nil)
   @subj = "probe"
  end
    
  def _planet(args = nil)
   @obj = "planet"
  end
  
  def _nearest(args = nil)
   @adj = "nearest"
  end
   
  def _vessel(arg = nil)        
   @obj = "vessel"
  end     
  
  
  def _engage (arg = nil)
    #debug "Call engage"
    begin
      ret = "Main drive engaged. Heading: #{@@ship.headingPoint}"
      @@ship.engage          
      resp_hash = {:str => ret, :success => true, :media => :plot_course}
    rescue RuntimeError => ex          
      resp_hash = {:str => ex, :success => false}
    end      
         
    return resp_hash
  end
  
  def _undock(args = nil)     
    #info "Call undock"
    begin
      @@ship.undock
      ret = "#{@@ship.name} undocked"
      if (!@obj.nil?)
         ret += " from #{@obj}"
      end
      resp_hash = {:str => ret, :success => true, :media => :travel}
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
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
   rescue RuntimeError => ex      
     resp_hash = {:str => ex, :success => false}
   end      
     
   return resp_hash
  end
  
  def _orbit(args = nil)     
     #info "Call orbit"
     begin      
       sgo = ShipSystem.find_sgo_from_name(@obj)     
       @@ship.orbit sgo
       if (!sgo.nil?)
         ret = "#{@@ship.name} in orbit around #{@obj}"       
       end
       resp_hash = {:str => ret, :success => true, :media => :plot_course}
     rescue RuntimeError => ex 
       resp_hash = {:str => ex, :success => false}
     end      
       
     return resp_hash  
  end
      
  def initialize
  end
   
  def to_s
      "I am the power system"
  end
  
  def self.cursor_str
         "Power"
  end
end

