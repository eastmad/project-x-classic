require "#{File.dirname(__FILE__)}/impl_security"

class ShipData
   attr_reader :name, :locationPoint, :status, :headingPoint   
   
   
  THRUSTERS = "Plasma thrusters"
  DRIVE = "Tunnel drive"
  JUMP = "Rift generator"
   
   def initialize(ship_name, locationPoint = nil)
      @name = ship_name
      @locationPoint = locationPoint
      @headingPoint = nil
      @status = :dependent
      @security = ImplSecurity.new
   end

   def set_heading(planet)
      raise "Cannot set course to #{planet}" unless (planet.kind_of? Planet) 
      #planet must be in system
      raise SystemsMessage.new("Cannot head for a planet not in this system", SystemNavigation, :info) unless (@locationPoint.body.owned_by? planet.owning_body)
          
      @headingPoint = planet.outerPoint
      info "Heading #{@headingPoint}"
      SystemsMessage.new("New heading is #{@headingPoint}", SystemNavigation, :info)
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
     raise SystemsMessage.new("Cannot head for a planet not in this system", SystemNavigation, :info) unless (@headingPoint.body.owned_by? @locationPoint.body.root_body)
           
     @locationPoint = @headingPoint
     @headingPoint = nil
     @state = :rest
     SystemsMessage.new("#{DRIVE} engaged", SystemPower, :info)
   end
   
   def approach(local_body)  
     inside = @locationPoint.body == local_body
     
     if (@status != :sync) 
       raise SystemsMessage.new("I can't fire directional thrusters unless we are in a stable orbit.", SystemPower, :info)
     end    

     lps = (@locationPoint.find_linked_location :satellite) + (@locationPoint.find_linked_location :approach)
     raise SystemsMessage.new("#{local_body} not in range of thrusters", SystemNavigation, :info) if (lps.empty? and !inside)
     raise SystemsMessage.new("Cannot approach #{local_body} safely with thrusters", SystemNavigation, :info) if (lps.empty? and inside)
     
     
     lp = lps.find {| lp | lp.body == local_body}
  
      
     unless lp.nil? 
      @locationPoint = lp
      @status = :rest
      SystemsMessage.new("#{THRUSTERS} fired", SystemPower, :info)
     else
      SystemsMessage.new("#{local_body} not in range", SystemNavigation, :info)
     end 
   end
   
   def orbit(planet)      
     raise SystemsMessage.new("Cannot orbit #{planet}", SystemNavigation, :info) unless (planet.kind_of? Planet) 
     raise SystemsMessage.new("#{@name} is in orbit around #{planet}", SystemNavigation, :info) if (@status == :sync and @locationPoint == planet.outerPoint)
     raise SystemsMessage.new("#{@name} is stationary", SystemNavigation, :info) if (@status ==:dependent)
     #location must be planet or there must be a link to orbit
     #state must be at rest

     orbit_point = @locationPoint.find_linked_location :orbit
     found_orbit_point = orbit_point.first.body == planet unless orbit_point.empty?
     info "found_orbit_point = #{found_orbit_point}"
     raise SystemsMessage.new("Cannot orbit #{planet} from #{@locationPoint}", SystemNavigation, :info) unless ((planet == @locationPoint.body or found_orbit_point) and @status != :sync)
         
     @status = :sync
     @locationPoint = planet.outerPoint
         
     SystemsMessage.new("#{@name} in orbit around #{planet}", SystemNavigation, :info)   
   end
   
   def dock(moon)
     raise SystemsMessage.new("#{@name} is already docked", SystemNavigation, :info) if (@status == :dependent)
     raise SystemsMessage.new("Cannot dock with #{moon}", SystemNavigation, :info) unless (moon.kind_of? Moon) 
     #location must be planet or moon
     #Either orbiting planet or atmoon
     if (moon == @locationPoint.body and (@status == :rest or @status == :sync))
       @status = :dependent
       @locationPoint = moon.surfacePoint
       return SystemsMessage.new("Docked with #{moon}", SystemPower, :info)
     else
       raise SystemsMessage.new("Cannot dock with #{moon} from #{@locationPoint}", SystemNavigation, :info)
     end   
   end
   
   def land(city)
     
     #location must be city     
     city_points = @locationPoint.find_linked_location :city
     raise SystemsMessage.new("No space ports found", SystemNavigation, :info) if city_points.empty? 

     #if a city specified check it is available to land at
     #take first for now
     target_point = city_points.first
     
     if (@status == :rest)
       @status = :dependent
       @locationPoint = target_point
       return SystemsMessage.new("Landed at #{target_point.body.name}", SystemPower, :info)
     else
       raise SystemsMessage.new("Cannot land on #{target_point.body.name} from #{@locationPoint}", SystemNavigation, :info)
     end   
   end
   
   
   def release_docking_clamp()
     ret = "Docking clamps are open"
     ret = "Docking clamps released" if @security.docking_clamps.unlock == :locked
     SystemsMessage.new(ret, SystemSecurity, :info)        
   end
   
   def lock_docking_clamp()
      ret = "Docking clamps are locked"
      ret = "Docking clamps locked" if @security.docking_clamps.lock == :unlocked
      SystemsMessage.new(ret, SystemSecurity, :info)        
   end
   
   def leave_orbit()
     #location must be planet
     raise SystemsMessage.new("Cannot leave orbit from #{@location}", SystemNavigation, :info) unless (@locationPoint.body.kind_of? Planet and @status == :sync)
           
     @status = :rest
     
     SystemsMessage.new("Leaving orbit of #{@locationPoint.body}", SystemPower, :info)
   end
   
   def up()
      if @locationPoint.has_link_type? :up
         @locationPoint = @locationPoint.find_linked_location(:up).first    
         @status = :rest
      else
         raise SystemsMessage.new("Movement prevented", SystemNavigation, :info)
      end
      
      SystemsMessage.new("#{THRUSTERS} on", SystemPower, :info)
   end
   
   def describeLocation()
      statusword = @locationPoint.body.status_word(@status, @locationPoint.band)
      "#{statusword} #{@locationPoint.body}"
   end
end