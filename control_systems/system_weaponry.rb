class SystemWeaponry < ShipSystem
  Operation.register_sys(:weaponry)  
  
  def _destroy(arg = nil)
    begin
      sgo = ShipSystem.find_sgo_from_name(arg)
      @@rq.enq @@ship.destroy(sgo)
      {:success => true}
    rescue => ex
      @@rq.enq ex
      {:success => false}
    end
  end
  
  def _load(arg = nil)
    begin
      @@rq.enq @@ship.load_torpedoes
      {:success => true}
    rescue => ex
      @@rq.enq ex
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
  
  def _nearest(arg = nil)     
   @adj = "nearest"
  end 
  
  def _enemy(arg = nil)     
   @adj = "enemy"
  end 
   
  def self.to_s
      "weaponry system online"
  end
  
  def self.cursor_str
    "weaponry:"
  end
  
  def self.status
    para1 = <<-END.gsub(/^ {4}/, '')
      weaponry system status      
      -#{@@ship.weaponry.torpedoes.size} torpedoes loaded.
    END
    @@rq.enq SystemsMessage.new(para1, SystemWeaponry, :response)
  end

end