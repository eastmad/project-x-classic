class SystemWeapon < ShipSystem
  Operation.register_sys(:weapon)  
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
   @subj = "torpedo" 
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
      
  def initialize
  end
   
  def to_s
      "Weapon system online"
  end
  
  def self.cursor_str
         "Weapons"
  end
end
