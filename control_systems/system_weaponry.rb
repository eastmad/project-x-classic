class SystemWeaponry < ShipSystem
  Operation.register_sys(:weaponry)  
  
  def _destroy(arg = nil)
    begin
      sgo = ShipSystem.find_sgo_from_name(arg)
      @@rq.enq @@ship.destroy(sgo)
      {:success => true}
    rescue => ex
      @@rq.enq ex
       @@rq.enq SystemsMessage.new("Torpedoes not fired.", SystemWeaponry, :response_bad)
      {:success => false}
    end
  end
  
  def _fire(arg = nil)     
    #info "Call fire"
      
    begin
      ret = "#{@subj} fired at #{@adj} #{@obj}" 
      resp_hash = {:str => ret, :success => true, :media => :travel}
    rescue RuntimeError => ex 
      resp_hash = {:str => ex, :success => false}
    end      
          
    return resp_hash 
  end   

  def _torpedo(arg = nil)     
   :torpedo 
  end   
  
  def _missile(arg = nil)        
   @subj = "torpedo" 
  end   

  def _cannon(arg = nil)     
   @subj = "cannon" 
  end   
  
  def _vessel(arg = nil)        
   @obj = "vessel"
  end
  
  def _weaponry(args = nil)
    
    para1 = SystemWeaponry.status
    @@rq.enq SystemsMessage.new("Weaponry\n\n#{para1}", SystemWeaponry, :report)
    
    {:success => true}
  end
  
  def _nearest(arg = nil)     
   @adj = "nearest"
  end 
  
  def _enemy(arg = nil)     
   @adj = "enemy"
  end 
   
  def self.to_s
      "Weapon systems"
  end
  
  def self.cursor_str
    "weaponry:"
  end
  
  def self.status
    num = @@ship.weaponry.torpedoes.size
    if num > 0
      torp_loaded = "#{num}x #{@@ship.weaponry.torpedoes[0].name}"
    else  
      torp_loaded = "No"
    end  
    para1 = <<-END.gsub(/^ {4}/, '')      
      > #{torp_loaded} loaded.
    END
  end

end
