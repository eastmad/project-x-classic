class SystemGhost < ShipSystem 
  #Operation.register_sys(:ghost)  

  def self.cursor_str
    "ghost:"
  end
  
  def self.welcome
    para1 = <<-END.gsub(/^ {6}/, '')
        Brother,
        
        You do not know me. And I cannot tell you yet
        why you are here. 
        
        You are in control of this small ship.
        Leave this solar system and I will contact you again.
    END
    
    para1
  end  
     
  def to_s
    "I'm here"
  end
end
