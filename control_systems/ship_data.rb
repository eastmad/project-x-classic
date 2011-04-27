require_relative "impl_security"
require_relative "impl_trade"
require_relative "impl_help"
require_relative "impl_mail"
require_relative "impl_contact"
require_relative "impl_weapon"

class ShipData
attr_reader :name, :locationPoint, :status, :headingPoint, :weapons   
 
 
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
    @contact = ImplContact.new
    @weapons = ImplWeapon.new 2
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
    @state = :sync 
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
  
  def load_torpedoes
info "load torps"
    raise SystemsMessage.new("You can only get ship services at a space station", SystemTrade, :info) unless (@status == :dependent and @locationPoint.body.kind_of? SpaceStation)
    #raise SystemsMessage.new("Cannot find any services offering torpedoes", SystemTrade, :info) if (item.nil? or !item.kind_of? Item)
info "check services offered"
    service = @trade.service_module_offered(@locationPoint.body, Torpedo.type)
info "offered #{service}"
    raise SystemsMessage.new("No source of service on offer", SystemTrade, :info) if service.nil?

    @weapons.load_torpedoes service
info "loaded"    
    SystemsMessage.new("Torpedoes loaded", SystemTrade, :info)  
  end
  
  def give(item)
    raise SystemsMessage.new("You can only move cargo in a trade station", SystemTrade, :info) unless (@status == :dependent and @locationPoint.body.kind_of? SpaceStation)
    raise SystemsMessage.new("Cannot find any tradable item", SystemTrade, :info) if (item.nil? or !item.kind_of? Item)
    trade_sink = nil
    begin
      trade_sink = @trade.sink_offered(@locationPoint.body, item)
    rescue
      raise SystemsMessage.new("Cannot find anyone wanting #{item}", SystemTrade, :info)
    end
    raise SystemsMessage.new("No request for #{item} is asked for", SystemTrade, :info) if trade_sink.nil?
 
    consignment = @trade.find_consignment(item)
 
    raise SystemsMessage.new("You have no consignment of #{item}", SystemTrade, :info) if consignment.nil?   
    
    trade_sink.give(consignment)
    @trade.cargo.delete consignment
 
    SystemsMessage.new("Consignment of #{item} taken from cargo hold", SystemTrade, :info)  
  end
  
 def contact(person)
   city =  @locationPoint.body
 
   raise SystemsMessage.new("You can only make contact in a city.", SystemCommunication, :info) unless city.kind_of? City
   raise SystemsMessage.new("You can only contact a person.", SystemCommunication, :info) unless person.kind_of? Contact    
   raise SystemsMessage.new("Cannot find #{person} in #{city}.", SystemCommunication, :info) unless city.contacts.include? person
    
   #check @meet.meet_me[name] for an entry
   mes = "#{person} doesn't want to meet you. You may not have anything #{person.he_or_she} wants."
   
   unless @contact.contacts.empty? or @contact.contacts[person.name].nil?
     #take into account no interest
     mes = "#{person} has already agreed to meet you. #{person.he_or_she.capitalize} is interested in #{@contact.contacts[person.name][:consignment]}"
   else
     mes = "#{person} has agreed to meet you. #{person.he_or_she.capitalize} is interested in #{@contact.contacts[person.name][:consignment]}" if @contact.check_cargo(person, @trade.cargo)
   end
   
   SystemsMessage.new(mes, SystemCommunication, :response)
 end
 
  def meet(person)
    raise SystemsMessage.new("You can only meet contacts in a city.", SystemCommunication, :response_bad) unless @locationPoint.body.kind_of? City
    raise SystemsMessage.new("You can only meet a person.", SystemCommunication, :response_bad) unless person.kind_of? Contact
  
    #check @meet.meet_me[name] for an entry
    
    unless @contact.contacts.empty? or @contact.contacts[person.name].nil?
      consignment = @contact.contacts[person.name][:consignment]
      unless @contact.contacts[person.name][:met]
        @trade.cargo.delete consignment
        #automatic increase of trust
        person.org.trust(1)
      end  
      @contact.contacts[person.name][:met] = true
    else
      info "Can't meet #{person}"
      #take into account no interest
      mes = "#{person} doesn't want to meet you. You may not have anything #{person.he_or_she} wants."
      mes =  "#{person} has not agreed to meet you. Contact #{person.him_or_her} first." unless @contact.contacts[person.name]
      raise SystemsMessage.new(mes, SystemCommunication, :response_bad) 
    end
    
    SystemsMessage.new("You met #{person}", SystemCommunication, :response)
  end
             
 def land(city)
   
   #location must be city     
   city_points = @locationPoint.find_linked_location :city
   raise SystemsMessage.new("No space ports found", SystemNavigation, :info) if city_points.empty? 
 
   #if a city specified check it is available to land at
   #take first for now
   target_point = city_points.first
   city_points.each do | lp |
      target_point = lp if lp.body == city
   end
   
   if (@status == :rest)
     @status = :dependent
     @locationPoint = target_point
     first_time = @locationPoint.body.visit
     
     if first_time
       city = @locationPoint.body
       para1 = "#{city}\n\n"
       para1 << city.describe
       para1 << "\n- " << city.desc
       para1 << "\n\n(Type 'describe #{city}' to see this)" 
 
       return SystemsMessage.new(para1, SystemLibrary, :report)
     else 
       return SystemsMessage.new("Landed at #{target_point.body.name}", SystemPower, :info)
     end
   else
     raise SystemsMessage.new("Cannot land on #{target_point.body.name} from #{@locationPoint}", SystemNavigation, :info)
   end   
 end
 
  def destroy target
    begin
info "target income = #{target}"
      outcome = @weapons.destroy target
info "weapons outcome = #{outcome}"
      mes = "Target destroyed." if outcome > 0
      mes = "Target disabled." if outcome == 0
      mes = "Target untouched." if outcome < 0
      SystemsMessage.new(mes, SystemWeapon, :info)
    rescue => ex
      raise SystemsMessage.new(ex, SystemWeapon, :info)  
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
    
  def up()
     if @locationPoint.has_link_type? :up
        @locationPoint = @locationPoint.find_linked_location(:up).first    
        @status = :sync
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