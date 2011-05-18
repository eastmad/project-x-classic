class SystemPower < ShipSystem
  Operation.register_sys(:power)
  
  def _launch(args=nil)   
    begin
      raise SystemsMessage.new("#{@@ship.name} is beyond launch stage", SystemMyself, :info) unless @@ship.status == :dependent
     
      @@rq.enq @@ship.release_docking_clamp()  #if (@@ship.docked?)
              
      @@rq.enq @@ship.up
      
      first_time = @@ship.locationPoint.body.visit
      
      if first_time
        para1 = SystemLibrary.desc @@ship.locationPoint.body
        @@rq.enq SystemsMessage.new(para1, SystemLibrary, :report)
      else
        SystemNavigation.status
      end  
        
      resp_hash = {:success => true, :media => :travel}
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Launch cancelled", SystemPower, :response_bad)
    end      
              
    return resp_hash     
  end   
  
  def _land(args=nil)   
    
    begin
      raise SystemsMessage.new("#{@@ship.name} is not within a planet's atmosphere", SystemPower, :info) unless @@ship.locationPoint.band == :atmosphere
      
      @obj = nil if args == @obj    
      unless args.nil?
        sgo = ShipSystem.find_sgo_from_name(@obj) unless @obj.nil?
        
        raise SystemsMessage.new("#{@@ship.name} is above #{@@ship.locationPoint.body} not #{sgo}", SystemPower, :info) if sgo.kind_of? Planet and @@ship.locationPoint.body != sgo        
        sgo ||= @@ship.locationPoint.body
        @@rq.enq SystemsMessage.new("#{@@ship.name} granted permission to land at #{sgo.name}", SystemCommunication, :info)
        @@rq.enq @@ship.land sgo         
      end                    
             
      #SystemNavigation.status
      resp_hash = {:success => true, :media => :land}
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("To land on a planet, first approach it from orbit.", SystemPower, :response_bad)
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
      sgo = ShipSystem.find_sgo_from_name(@obj) unless @obj.nil?     
      
      if sgo.nil?
        sgo = @@ship.locationPoint.body
      end  
      
      @@rq.enq @@ship.dock sgo
      @@rq.enq @@ship.lock_docking_clamp()
      @@rq.enq SystemsMessage.new("'#{sgo.welcome}'", SystemCommunication, :info)

      resp_hash = {:success => true, :media => :docking}
    rescue RuntimeError => ex      
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Docking manoeuvre not attempted", SystemPower, :response_bad)
    end      
        
    return resp_hash
  end
  
  def _undock(args = nil)     
      #info "Call undock"
      begin
      
        @@rq.enq @@ship.release_docking_clamp()
        
        @@rq.enq @@ship.up

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
      
      first_time = @@ship.locationPoint.body.visit
      
      if first_time
        para1 = SystemLibrary.desc @@ship.locationPoint.body
        @@rq.enq SystemsMessage.new(para1, SystemLibrary, :report)
      else
        SystemNavigation.status
      end 
      
      resp_hash = {:success => true, :media => :drive}
    rescue RuntimeError => ex          
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("#{ShipData::DRIVE} not engaged", SystemPower, :response_bad)
    end      
         
    return resp_hash
  end
  
  def _approach (arg = nil)
    begin
      raise SystemsMessage.new("Approach what? No target given.", SystemMyself, :info) if arg.nil?
      sgo = ShipSystem.find_sgo_from_name(arg)
      raise SystemsMessage.new("Cannot locate target", SystemNavigation, :info) if sgo.nil?
      
      @@rq.enq @@ship.approach sgo   
        
      SystemNavigation.status
        
      resp_hash = {:success => true, :media => :atmosphere}
    rescue RuntimeError => ex          
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("#{ShipData::THRUSTERS} not fired", SystemPower, :response_bad)
    end      
           
    return resp_hash
  end

      
  def initialize
  end
  
  def self.status
    para1 = <<-END.gsub(/^ {4}/, '')    
      - #{ShipData::THRUSTERS} online.
      - #{ShipData::DRIVE} online.
      - #{ShipData::JUMP} charged.
    END
  end
   
  def self.to_s
    "Power system"
  end
  
  def self.cursor_str
     "power:"
  end
end

