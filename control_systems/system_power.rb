class SystemPower < ShipSystem
  Operation.register_sys(:power)
  
  def _launch(args=nil)
    
    begin
      if (args.nil?)
         ret = "#{@@ship.name} launched"   
      else
        ret = "#{@subj} launched towards #{@adj} #{@obj}"   
      end       
      resp_hash = {:str => ret, :success => true, :media => :travel}
      @@rq.enq SystemsMessage.new(ret, SystemPower, :response) 
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("launch cancelled", SystemPower, :response_bad)
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
  
  def _dock(args = nil)     
      #info "Call dock"
      begin
        sgo = find_sgo_from_name(@obj) unless @obj.nil?     
        @@ship.dock sgo
        ret = "#{@@ship.name} docked"      
        if (!sgo.nil?)
           ret += " to #{@obj}"
        end
        resp_hash = {:success => true, :media => :docking}
        @@rq.enq SystemsMessage.new(ret, PowerNavigation, :response)
      rescue RuntimeError => ex      
        resp_hash = {:success => false}
        @@rq.enq ex
        @@rq.enq SystemsMessage.new("Docking manoeuvre not attempted", PowerNavigation, :response_bad)
      end      
        
      return resp_hash
  end
  
  def _undock(args = nil)     
      #info "Call undock"
      begin
        @@ship.undock
        if (!@obj.nil?)
           ret += " from #{@obj}"
        end

        @@rq.enq @@ship.release_docking_clamp()
        
        @@rq.enq @@ship.out

        SystemNavigation.status
        
        resp_hash = {:success => true, :media => :travel}
      rescue RuntimeError => ex 
        resp_hash = {:success => false}
        @@rq.enq ex
        @@rq.enq SystemsMessage.new("Cannot undock", SystemPower, :response_bad)
      end      
         
      return resp_hash  
  end
  
  
  def _engage (arg = nil)
    #debug "Call engage"
    begin
      @@rq.enq @@ship.engage   
      
      SystemNavigation.status
      
      resp_hash = {:success => true, :media => :drive}
    rescue RuntimeError => ex          
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("#{SHipData::DRIVE} not engaged", SystemPower, :response_bad)
    end      
         
    return resp_hash
  end
  
  def _orbit(args = nil)     
     #info "Call orbit"
     begin      
       sgo = ShipSystem.find_sgo_from_name(@obj)     
       @@rq.enq @@ship.orbit sgo
       if (!sgo.nil?)
         ret = "#{@@ship.name} in orbit around #{@obj}"       
       end
       resp_hash = {:str => ret, :success => true, :media => :plot_course}
     rescue RuntimeError => ex 
       resp_hash = {:str => ex, :success => false}
       @@rq.enq ex
       @@rq.enq SystemsMessage.new("Cannot enter orbit", SystemPower, :response_bad)
     end      
       
     return resp_hash  
  end
      
  def initialize
  end
  
  def self.status
    para1 = <<-END.gsub(/^ {4}/, '')
      Propulsion system status      
      -#{ShipData::THRUSTERS} online.
      -#{ShipData::DRIVE} online.
      -#{ShipData::JUMP} charged.
    END
    @@rq.enq SystemsMessage.new(para1, SystemPower, :response)
  end
   
  def to_s
    "I am the power system"
  end
  
  def self.cursor_str
     "Power"
  end
end

