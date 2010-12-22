class SimpleBody
 

 attr_reader :name, :desc, :owning_body, :boundary_point
 
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

end