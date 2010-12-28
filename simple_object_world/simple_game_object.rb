class City < SimpleBody      
   attr_reader :centrePoint
   attr_accessor :links
   
   def initialize(name, desc, ownerPoint)      
      super(name, desc, ownerPoint.body)
      @links = []
      
      @centrePoint = LocationPoint.new(self, :centre)               
      @centrePoint.add_link([:up, :launch], ownerPoint) 
      ownerPoint.add_link([:city, :land], @centrePoint)   
   end      

   def owned_by? body
      return false if @owning_body.nil?
      return true if @owning_body == body 
      
      return @owning_body.owned_by? body 
   end
   
   def status_word(status, band)
      "parked in"

   end
   
   def describe
      "#{@name} is a space port of #{@owning_body.name}"
   end
   
   def describe_owns
       "No contacts known."
   end
   
   def to_s
     @name
   end
end


class CelestialObject < SimpleBody      
   attr_reader :centrePoint, :outerPoint, :surfacePoint
   attr_accessor :links
   
   def initialize(name, desc = "Nondescript", owning = nil)      
      super(name, desc, owning)
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
   def initialize(name, desc, owner = nil)      
      super(name, desc, owner)
      
      @centrePoint = LocationPoint.new(self, :centre)
      lp2 = LocationPoint.new(self, :photosphere)
      lp3 = LocationPoint.new(self, :inner_orbit)
      @outerPoint = LocationPoint.new(self, :outer_orbit)      
      
      @centrePoint.add_link([:up],lp2)
      lp2.add_link([:up],lp3)
      lp3.add_link([:up], @outerPoint)
      
   end
   
   def status_word(status, band)
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
   
   def describe_owns 
      planets = owns.collect{|locPoint| locPoint.body}
      "The orbiting planets are #{planets.join(', ')}"
   end
      
end


class Planet < CelestialObject

   attr_reader :orbitPoint, :atmospherePoint
   
   def initialize(name, desc, ownerPoint)      
      super(name, desc, ownerPoint.body)
      
      @centrePoint = LocationPoint.new(self, :centre)      
      @surfacePoint = LocationPoint.new(self, :surface)
      @atmospherePoint = LocationPoint.new(self, :atmosphere)
      @outerPoint = LocationPoint.new(self, :geo_orbit)      
            
      @centrePoint.add_link([:up], @surfacePoint)
      @surfacePoint.add_link([:up], @atmospherePoint)
      @atmospherePoint.add_link([:up],@outerPoint)       
      
      @outerPoint.add_link([:star], ownerPoint)  
      @outerPoint.add_link([:approach], @atmospherePoint)
      ownerPoint.add_link([:planet], @outerPoint)      
   end
   
   def describe
      "#{@name} is a planet orbiting #{@owning_body.name}"
   end
   
   def owns
       @outerPoint.find_linked_location(:satellite)
   end
   
   def describe_owns 
       ret = "No orbiting bodies"
       satellites = owns.collect{|locPoint| locPoint.body}
       cities = @atmospherePoint.find_linked_location(:city).collect{|cityPoint| cityPoint.body}
       ret = "The orbiting satellites are #{satellites.join(', ')}" unless satellites.empty? 
       ret << "\n- City ports are #{cities.join(', ')}" unless cities.empty? 
       ret
   end

   def status_word(status, band)
      if status == :rest
         if band == :atmosphere
            sw = "in atmosphere of"
         else
            sw = "above"
         end
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

   


end

class Moon < CelestialObject
   def initialize(name, desc, ownerPoint)      
      super(name, desc, ownerPoint.body)

      @centrePoint = LocationPoint.new(self, :centre)   
      @surfacePoint = LocationPoint.new(self, :surface)
      @outerPoint = LocationPoint.new(self, :outer)
                  
      @centrePoint.add_link([:up], @surfacePoint)
      @surfacePoint.add_link([:up], @outerPoint)
      @outerPoint.add_link([:dock], @surfacePoint)
      
      @outerPoint.add_link([:planet, :orbit], ownerPoint) 
      ownerPoint.add_link([:satellite], @outerPoint)      
   end
   
   def status_word(status, band)
      if status == :rest
         sw = "above"
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

   def describe_owns 
      "No registered companies."
   end


end
