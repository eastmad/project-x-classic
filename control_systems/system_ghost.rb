class SystemGhost < ShipSystem 
  #Operation.register_sys(:ghost)  

  def self.cursor_str
    "ghost:"
  end
  
  def self.welcome
    para1 = <<-END.gsub(/^ {8}/, '')
        Brother,
        
        You do not know me. And I cannot 
        tell you yet why you are here. 
        You are in control of this small ship.
        You must leave this solar system before i 
        can contact you any again.
        
        Fit your ship out and use the gate.
    END
    
    SystemsMessage.new(para1, SystemGhost, :mail)
  end  
  
  def _mission(args = nil)
   
    if @subj.nil?
      para1 = <<-END.gsub(/^ {8}/, '')
        Brother,
        
        You do not know me. And I cannot tell you yet
        why you are here. 
        
        You are in control of this small ship #{@@ship.name}
        
        You must leave this solar system before i can contact 
        you any again.
      END
    else
       para1 = "Incomplete."
    end
      
    @@rq.enq SystemsMessage.new(para1, SystemGhost, :ghost)
    return {:success => true}
  end
     
  def to_s
    "I'm here"
  end
end
