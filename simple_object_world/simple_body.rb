class SimpleBody
 

 attr_reader :name, :owning_body, :boundary_point
 
 def initialize name, owner = nil
   @name = name
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