require "#{File.dirname(__FILE__)}/impl_security"
require "#{File.dirname(__FILE__)}/impl_trade"
require "#{File.dirname(__FILE__)}/impl_help"
require "#{File.dirname(__FILE__)}/impl_mail"

class ShipData
  attr_reader :name, :locationPoint, :status, :headingPoint   
   
   
  THRUSTERS = "Plasma thrusters"
  DRIVE = "Tunnel drive"
  JUMP = "Rift generator"
   
   def initialize(ship_name, locationPoint)
      @name = ship_name
      @locationPoint = locationPoint
      @headingPoint = nil
      @status = :rest
      @status = :dependent if locationPoint.has_link_type? :launch   
      @security = ImplSecurity.new
      @trade = ImplTrade.new
      @help = ImplHelp.new
      @mail = ImplMail.new
   end
   
   def push_mail(txt, from)
      @mail.accept_mail(txt, from)
   end

   def has_new_mail?
      @mail.read_mail(:position => :new, :consume => false)
   end
   
   def read_mail(opts = {})
      @mail.read_mail(opts)
   end
   
   def suggest
      SystemsMessage.new(@help.suggest(@locationPoint, @status), SystemMyself, :respond)
   end

   def set_heading(planet)
      raise "Cannot set course to #{planet}" unless (planet.kind_of? Planet) 
      #planet must be in system
      raise SystemsMessage.new("Cannot head for a planet not in this system", SystemNavigation, :info) unless (@locationPoint.body.owned_by? planet.owning_body)
          
      @headingPoint = planet.orbitPoint
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
     raise SystemsMessage.new("#{@name} is in orbit around #{planet}", SystemNavigation, :info) if (@status == :sync and @locationPoint == planet.orbitPoint)
     raise SystemsMessage.new("#{@name} is stationary", SystemNavigation, :info) if (@status ==:dependent)
     raise SystemsMessage.new("Cannot orbit #{planet}", SystemNavigation, :info) unless (planet.kind_of? Planet) 
     
     #location must be planet or there must be a link to orbit
     #state must be at rest

     orbit_point = @locationPoint.find_linked_location :orbit
     found_orbit_point = orbit_point.first.body == planet unless orbit_point.empty?
     info "found_orbit_point = #{found_orbit_point}"
     raise SystemsMessage.new("Cannot orbit #{planet} from #{@locationPoint}", SystemNavigation, :info) unless ((planet == @locationPoint.body or found_orbit_point) and @status != :sync)
         
     @status = :sync
     @locationPoint = planet.orbitPoint
         
     SystemsMessage.new("#{@name} in orbit around #{planet}", SystemNavigation, :info)   
   end
   
   def dock(spaceStation)
     raise SystemsMessage.new("#{@name} is already docked", SystemNavigation, :info) if (@status == :dependent)
     raise SystemsMessage.new("Cannot dock with #{spaceStation}", SystemNavigation, :info) unless (spaceStation.kind_of? SpaceStation) 
     #location must be planet or spaceStation
     #Either orbiting planet or atspaceStation
     if (spaceStation == @locationPoint.body and (@status == :rest or @status == :sync))
       @status = :dependent
       @locationPoint = spaceStation.surfacePoint
       return SystemsMessage.new("Docked with #{spaceStation}", SystemPower, :info)
     else
       raise SystemsMessage.new("Cannot dock with #{spaceStation} from #{@locationPoint}", SystemNavigation, :info)
     end   
   end
   
   def bay bay_number
      @trade.bay(bay_number) if bay_number > 0 and bay_number <= 6
   end
   
   def manifest
     @trade.manifest
   end
   
   def accept(item)
     raise SystemsMessage.new("You can only accept a contract at a trade station", SystemTrade, :info) unless (@status == :dependent and @locationPoint.body.kind_of? SpaceStation)
     raise SystemsMessage.new("Cannot find any tradable item", SystemTrade, :info) if (item.nil? or !item.kind_of? Item)
     trade = @trade.source_offered(@locationPoint.body, item)
     raise SystemsMessage.new("No source of #{item} on offer", SystemTrade, :info) if trade.nil?
     
     trade.status = :accepted
     
     @trade.cargo << trade.accept()
     
     SystemsMessage.new("Consignment of #{item} added to cargo hold", SystemTrade, :info)  
   end
   
   def fulfill(item)
     info "fulfill"
     raise SystemsMessage.new("You can only fulfill a contract at a trade station", SystemTrade, :info) unless (@status == :dependent and @locationPoint.body.kind_of? SpaceStation)
     info "at station"
     raise SystemsMessage.new("Cannot find any tradable item", SystemTrade, :info) if (item.nil? or !item.kind_of? Item)
     info "item #{item}"
     trade = nil
     begin
       info "sink offered for #{@locationPoint.body}"
       trade = @trade.sink_offered(@locationPoint.body, item)
       info "done"
     rescue
       raise SystemsMessage.new("Cannot find sink for #{item}", SystemTrade, :info)
     end
     raise SystemsMessage.new("No request for #{item} is asked for", SystemTrade, :info) if trade.nil?
  
     consignment = @trade.find_consignment(item)
 
     raise SystemsMessage.new("You have no consignment of #{item}", SystemTrade, :info) if consignment.nil?   
     
     trade.fulfill(consignment)
     @trade.cargo.delete consignment
  
     SystemsMessage.new("Consignment of #{item} taken from cargo hold", SystemTrade, :info)  
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