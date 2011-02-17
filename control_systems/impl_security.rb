class ImplSecurity
  attr_reader :docking_clamps 
   
  def initialize
    @docking_clamps = DoorMechanic.new(:locked) 
  end

end

class DoorMechanic
  
  def initialize state
    @state = state  
  end
  
  def locked?
    return false if @state == :locked
  
    return true
  end
  
  def lock
    original_state = @state
    @state = :locked
    
    original_state
  end

  def unlock
    original_state = @state
    @state = :unlocked
    
    original_state
  end
end