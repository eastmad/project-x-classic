require_relative "impl_security"
require_relative "impl_trade"
require_relative "impl_help"
require_relative "impl_mail"
require_relative "impl_contact"
require_relative "impl_weaponry"
require_relative "impl_modification"

class ShipData
attr_reader :name, :locationPoint, :status, :headingPoint, :icontact, :trade, :mail, :weaponry, :modification   
 
 
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
    @icontact = ImplContact.new
    @weaponry = ImplWeaponry.new 2
    @modification = ImplModification.new
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
     @help.suggest(@locationPoint, @status)
  end
  
  #!@modification.mod_type_present? :shield
 
  def check_security(obj)
    info "checking blockers"
    obj.blockers.each do | blocker |
      info "consider blocker on #{obj}"
      if blocker[:active] and method(blocker[:check_method]).call(blocker[:to_check])
        info "block engaged #{blocker[:statement]}"
        raise SystemsMessage.new(blocker[:statement], SystemSecurity, :info)
      end
    end
  end
 
 def check_mod(mod_type)
    !@modification.mod_type_present? mod_type
 end
 
 def check_torp_class(class_to_check)
    torp = @weaponry.torpedoes[0]
    torp.kind_of? class_to_check
 end 
 
  def set_heading(planet)
     raise SystemsMessage.new("#{planet} is not a planet",SystemNavigation, :info) unless (planet.kind_of? Planet) 
     #planet must be in system
     raise SystemsMessage.new("Cannot head for a planet not in this system", SystemNavigation, :info) unless (@locationPoint.body.owned_by? planet.owning_body)
     check_security(planet)    
         
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
    raise SystemsMessage.new("Cannot head for a planet not in this system", SystemNavigation, :info) unless (@headingPoint.body.owned_by? @locationPoint.body.local_star)
          
    @locationPoint = @headingPoint
    @headingPoint = nil
    @state = :sync 
    SystemsMessage.new("#{DRIVE} engaged", SystemPower, :info)
  end
  
  def approach(local_body)
    inside = @locationPoint.body == local_body
    info "in approach #{local_body}"    
 
    lps = (@locationPoint.find_linked_location :satellite) + (@locationPoint.find_linked_location :approach)
    raise SystemsMessage.new("#{local_body} not in range of thrusters", SystemNavigation, :info) if (lps.empty? and !inside)
    raise SystemsMessage.new("Cannot approach #{local_body} safely with thrusters", SystemNavigation, :info) if (lps.empty? and inside)
    
    lp = lps.find {| lp | info "lps = #{lp.body}";lp.body == local_body}
    
    info "exit approach #{lp}"
    
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
    raise SystemsMessage.new("Cannot establish an orbit around #{planet}", SystemNavigation, :info) unless (planet.kind_of? Planet) 
    
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
  
  
  def all_mod_cons
    raise SystemsMessage.new("No modifications to original design added", SystemModification, :response) if @modification.mods.empty?
    @modification.all_mod_cons
  end
  
  def bay bay = "red"
    info "bay = #{bay}"
    raise SystemsMessage.new("Cargo bays empty", SystemTrade, :response) if @trade.cargo.empty?
    if (ImplTrade::Bay_colour_map.keys.include? bay)
      resp = @trade.bay(bay)
      raise SystemsMessage.new("Cargo bay #{bay} is empty", SystemTrade, :response_bad) if resp.empty? 
    else
      resp = @trade.manifest
    end
    
    resp
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
  
  def install mod_type
    raise SystemsMessage.new("You can only install modules at a space station", SystemModification, :info) unless (@status == :dependent and @locationPoint.body.kind_of? SpaceStation)
    #raise SystemsMessage.new("Cannot find any services offering torpedoes", SystemTrade, :info) if (item.nil? or !item.kind_of? Item)
    offered_module = @trade.service_module_offered(@locationPoint.body, mod_type)
    raise SystemsMessage.new("No source of module on offer", SystemTrade, :info) if offered_module.nil?

    inst_mod = @modification.install offered_module
    SystemsMessage.new("#{offered_module.name} installed - #{inst_mod.desc}", SystemModification, :info)  
  end

  
  def load_torpedoes
    raise SystemsMessage.new("You can only load torpdeoes at a space station", SystemWeaponry, :info) unless (@status == :dependent and @locationPoint.body.kind_of? SpaceStation)
    #raise SystemsMessage.new("Cannot find any services offering torpedoes", SystemTrade, :info) if (item.nil? or !item.kind_of? Item)
    torps = @trade.service_module_offered(@locationPoint.body, Torpedo.type)
    raise SystemsMessage.new("No torpdoes on offer", SystemTrade, :info) if torps.nil?

    loaded_torp = @weaponry.load_torpedoes torps
    SystemsMessage.new("#{torps.name} loaded - #{loaded_torp.desc}", SystemWeaponry, :info)  
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
    
    begin
      trade_sink.give(consignment)
    rescue => ex
      raise SystemsMessage.new(ex.to_s, SystemTrade, :info)
    end  
    @trade.cargo.delete consignment
      
 
    SystemsMessage.new("Consignment of #{item} taken from cargo hold", SystemTrade, :info)  
  end
  
  def contact(person)
    city =  @locationPoint.body

    raise SystemsMessage.new("You can only make contact in a city.", SystemCommunication, :info) unless city.kind_of? City
    raise SystemsMessage.new("You can only contact a person.", SystemCommunication, :info) unless person.kind_of? Contact    
    raise SystemsMessage.new("Cannot find #{person} in #{city}.", SystemCommunication, :info) unless city.contacts.include? person

    #check @meet.meet_me[name] for an entry
    mes = person.not_interested_string

    if @icontact.contacted? person
      mes = person.already_agreed_meet_string
    else    
      if @icontact.interested?(person, @trade.cargo)
        mes = person.agreed_meet_string
        @icontact.contact_made(person)
      end
    end
  
    SystemsMessage.new(mes, SystemCommunication, :response)
  end
 
  def meet(person)
    city =  @locationPoint.body
    
    raise SystemsMessage.new("You can only meet contacts in a city.", SystemCommunication, :info) unless city.kind_of? City
    raise SystemsMessage.new("You can only meet a person.", SystemCommunication, :info) unless person.kind_of? Contact
    raise SystemsMessage.new("Cannot find #{person} in #{city}.", SystemCommunication, :info) unless city.contacts.include? person
    
    if @icontact.contacted? person
      if @icontact.interested? person, @trade.cargo   
        unless @icontact.met? person
          @trade.cargo.delete @icontact.find_interesting_consignment person, @trade.cargo
          #automatic increase of trust
          person.org.trust(1)
          @icontact.contact_met person
          mes = "You met #{person}"
        else
          mes = person.already_met_string
        end
      else
        mes = person.not_interested_string
      end
    else
      mes = "Contact #{person} first. It's only polite."
    end
    
    SystemsMessage.new(mes, SystemCommunication, :info)
  end
             
 def land(city_point)
   
   #location must be city     
   #city_points = @locationPoint.find_linked_location :city
   #raise SystemsMessage.new("No space ports found", SystemNavigation, :info) if city_points.empty? 
 
   #if a city specified check it is available to land at
   #take first for now
   #target_point = city_points.first
   #city_points.each do | lp |
   #   target_point = lp if lp.body == city
   #end
   
   if (@status == :rest)
     @status = :dependent
     @locationPoint = city_point
     
     #first_time = @locationPoint.body.visit
     #
     #if first_time
     #  city = @locationPoint.body
     #  para1 = "#{city}\n\n"
     #  para1 << city.describe
     #  para1 << "\n- " << city.desc
     #  para1 << "\n- " << city.describe_owns 
 
      # return SystemsMessage.new(para1, SystemLibrary, :report)
     #else 
     #  return SystemsMessage.new("Landed at #{city_point.body.name}", SystemPower, :info)
     #end
   else
     raise SystemsMessage.new("Cannot land on #{city_point.body.name} from #{@locationPoint}", SystemNavigation, :info)
   end   
 end
 
  def destroy target
    raise SystemsMessage.new("Not a structure available weaponry can damage.", SystemWeaponry, :info) unless target.kind_of? SmallStructure
    raise SystemsMessage.new("No torpedoes loaded",SystemWeaponry, :info) unless @weaponry.torpedoes.size > 0
    raise SystemsMessage.new("Structure has insufficient integrity to target",SystemWeaponry, :info) if target.status == :destroyed 

    check_security(target)
    outcome = @weaponry.destroy target
    
    raise SystemsMessage.new("Torpedoes loaded are too small to damage target",SystemWeaponry, :info) if outcome < 0
    
    mes = "Target destroyed." if outcome > 0
    mes = "Target disabled." if outcome == 0
    mes = "Target untouched." if outcome < 0
    SystemsMessage.new(mes, SystemWeaponry, :info) 
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