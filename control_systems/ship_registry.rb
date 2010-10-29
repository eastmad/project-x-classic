class ShipRegistry
   private_class_method :new
   @@ships = nil
   
   def self.register_ship(ship_name, location = nil)
      @@ships = Array.new unless @@ships
      
      ship = ShipData.new(ship_name, location)
      @@ships << ship
      
      return ship
   end     
      
end

class ShipData
   attr_reader :name, :locationPoint, :status, :headingPoint   
   
   def initialize(ship_name, locationPoint = nil)
      @name = ship_name
      @locationPoint = locationPoint
      @headingPoint = nil
      @status = :dependent
   end

   def set_heading(planet)
      raise "Cannot set course to #{planet}" unless (planet.kind_of? Planet) 
      #planet must be in system
      if (@locationPoint.body.owned_by? planet.owning_body)
          @headingPoint = planet.outerPoint
          info "Heading #{@headingPoint}"
      else
          raise "Cannot head for a planet not in this system"
      end   
   end
   
   def engage      
       raise SystemsMessage.new("I am not aware of any desired heading", SystemNavigation, :info) if @headingPoint.nil?
       raise SystemsMessage.new("Heading is not a planet", SystemNavigation, :info) unless (@headingPoint.body.kind_of? Planet)
       if (@status == :dependent) 
           raise SystemsMessage.new("I can't engage main drive while docked", SystemSecurity, :info)
       end    
       #location must be planet in system
       info "heading body #{@headingPoint.body}"
       info "location owner body #{@locationPoint.body.root_body}"
       if (@headingPoint.body.owned_by? @locationPoint.body.root_body)
           @locationPoint = @headingPoint
           @headingPoint = nil
           @state = :rest
       else
           raise SystemsMessage.new("Cannot head for a planet not in this system", SystemNavigation, :info)
       end         
   end
   
   def orbit(planet)      
      raise SystemsMessage.new("Cannot orbit #{planet}", SystemNavigation, :info) unless (planet.kind_of? Planet) 
      #location must be planet or a moon of it
      #state must be at rest
      if ((planet == @locationPoint.body or planet == @locationPoint.body.owning_body) and @status != :sync)
         @status = :sync
         @locationPoint = planet.orbitPoint
      else
         raise SystemsMessage.new("Cannot orbit #{planet} from #{@locationPoint}", SystemNavigation, :info)
      end   
   end
   
   def dock(moon)
      raise SystemsMessage.new("#{@name} is already docked", SystemNavigation, :info) if (@status == :dependent)
      raise SystemsMessage.new("Cannot dock with #{moon}", SystemNavigation, :info) unless (moon.kind_of? Moon) 
      #location must be planet or moon
      #Either orbiting planet or atmoon
      if ((moon == @locationPoint.body and @status == :rest) or (moon == @locationPoint.body and @status == :sync))
         @status = :dependent
         @locationPoint = moon.outerPoint
      else
         raise SystemsMessage.new("Cannot dock with #{moon} from #{@locationPoint}", SystemNavigation, :info)
      end   
   end
   
   def undock()
      #location must be moon
      if (@locationPoint.body.kind_of? Moon and @status == :dependent)
         @status = :rest
      else
         raise SystemsMessage.new("Cannot undock from #{@location}", SystemSecurity, :info)
      end   
   end
   
   def leave_orbit()
      #location must be planet
      if (@locationPoint.body.kind_of? Planet and @status == :dependent)
           @status = :rest
      else
          raise SystemsMessage.new("Cannot leave orbit from #{@location}", SystemNavigation, :info)
      end   
   end
   
   def describeLocation()
      statusword = @locationPoint.body.status_word(@status)
      "#{statusword} #{@locationPoint.body}"
   end
end







