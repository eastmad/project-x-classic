
class CelestialObject < SimpleBody      
   attr_reader :centrePoint
   attr_reader :outerPoint
   attr_accessor :links
   
   def initialize(name, owning = nil)      
      super(name, owning)
      @links = []
   end      

   def owned_by? body
      return false if @owning_body.nil?
      return true if @owning_body == body 
      
      return @owning_body.owned_by? body 
   end
     
   def to_s
     @name
   end
end

class Star < CelestialObject      
   def initialize(name, owner = nil)      
      super(name, owner)
      
      @centrePoint = LocationPoint.new(self, :centre)
      lp2 = LocationPoint.new(self, :photosphere)
      lp3 = LocationPoint.new(self, :inner_orbit)
      @outerPoint = LocationPoint.new(self, :outer_orbit)      
      
      @centrePoint.add_link(:up,lp2)
      lp2.add_link(:up,lp3)
      lp3.add_link(:up, @outerPoint)
      
   end
   
   
   def describe
     "#{@name} is a star within the galaxy"
   end
   
   def owns
      @outerPoint.findLinkedLocPoint(:planet).body
   end
      
end


class Planet < CelestialObject

   attr_reader :orbitPoint
   
   def initialize(name, ownerPoint)      
      super(name, ownerPoint.body)
      
      @centrePoint = LocationPoint.new(self, :centre)      
      lp2 = LocationPoint.new(self, :surface)
      lp3 = LocationPoint.new(self, :atmosphere)
      @outerPoint = LocationPoint.new(self, :geo_orbit)      
            
      @centrePoint.add_link(:up, lp2)
      lp2.add_link(:up, lp3)
      lp3.add_link(:up,@outerPoint)       
      
      @outerPoint.add_link(:star, ownerPoint)      
      ownerPoint.add_link(:planet, @outerPoint)      
   end
   
   def describe
      "#{@name} is a planet orbiting #{@owning_body.name}"
   end
   
   def owns
      @outerPoint.findLinkedLocPoint(:satellite).body
   end

end

class Moon < CelestialObject
   def initialize(name, ownerPoint)      
      super(name, ownerPoint.body)

      @centrePoint = LocationPoint.new(self, :centre)                
      @outerPoint = LocationPoint.new(self, :surface)
                  
      @centrePoint.add_link(:up, @outerPoint)
      
      @outerPoint.add_link(:planet, ownerPoint) 
      ownerPoint.add_link(:satellite, @outerPoint)      
   end
   
   def describe
      "#{@name} is a satellite of #{@owning_body.name}"
   end

end
