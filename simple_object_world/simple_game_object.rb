
class CelestialObject < SimpleBody      
   attr_reader :centrePoint, :outerPoint, :surfacePoint
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
      
      @centrePoint.add_link([:up],lp2)
      lp2.add_link([:up],lp3)
      lp3.add_link([:up], @outerPoint)
      
   end
   
   def status_word(status)
      if status == :rest
         sw = "within"
      elsif status == :sync
         sw = "orbiting"
      elsif status == :dependent
         sw = "ash on"
      end
      
      sw
   end
      
   def describe
     "#{@name} is a star within the galaxy"
   end
   
   def owns
      @outerPoint.find_linked_location(:planet)
   end
      
end


class Planet < CelestialObject

   attr_reader :orbitPoint
   
   def initialize(name, ownerPoint)      
      super(name, ownerPoint.body)
      
      @centrePoint = LocationPoint.new(self, :centre)      
      @surfacePoint = LocationPoint.new(self, :surface)
      lp3 = LocationPoint.new(self, :atmosphere)
      @outerPoint = LocationPoint.new(self, :geo_orbit)      
            
      @centrePoint.add_link([:up], @surfacePoint)
      @surfacePoint.add_link([:up], lp3)
      lp3.add_link([:up],@outerPoint)       
      
      @outerPoint.add_link([:star], ownerPoint)      
      ownerPoint.add_link([:planet], @outerPoint)      
   end
   
   def describe
      "#{@name} is a planet orbiting #{@owning_body.name}"
   end

   def status_word(status)
      if status == :rest
         sw = "in vicinity of"
      elsif status == :sync
         sw = "orbiting"
      elsif status == :dependent
         sw = "parked on"
      end
      
      sw
   end

   def out
      :star
   end

   
   def owns
      @outerPoint.find_linked_location(:satellite)
   end

end

class Moon < CelestialObject
   def initialize(name, ownerPoint)      
      super(name, ownerPoint.body)

      @centrePoint = LocationPoint.new(self, :centre)   
      @surfacePoint = LocationPoint.new(self, :surface)
      @outerPoint = LocationPoint.new(self, :outer)
                  
      @centrePoint.add_link([:up], @surfacePoint)
      @surfacePoint.add_link([:up], @outerPoint)
      @outerPoint.add_link([:dock], @surfacePoint)
      
      @outerPoint.add_link([:planet, :orbit], ownerPoint) 
      ownerPoint.add_link([:satellite], @outerPoint)      
   end
   
   def status_word(status)
      if status == :rest
         sw = "in vicinity of"
      elsif status == :sync
         sw = "orbiting"
      elsif status == :dependent
         sw = "docked with"
      end
      
      sw
   end

   def out
      :planet
   end

   def describe
      "#{@name} is a satellite of #{@owning_body.name}"
   end

end
