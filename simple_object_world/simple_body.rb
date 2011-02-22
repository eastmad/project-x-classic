class SimpleBody

 attr_reader :name, :desc, :owning_body, :boundary_point
 @@outgoing_mail = []
 
 def initialize name, desc = "Unknown origin", owner = nil
   @name = name
   @desc = desc
   @owning_body = owner
 end
 
 def root_body
   body = self
   until body.owning_body.nil?
      body = body.owning_body
   end
   
   body
 end
 
 def push_message txt, from
   @@outgoing_mail << Mail.new(txt, from) 
 end

 def self.get_mail
    @@outgoing_mail
 end

end

class Mail
  attr_reader :txt, :from, :read  
    
  def initialize txt, from
    @txt = txt
    @from = from
    @read = false       
  end
  
  def consume
    @read = true
  end
end
