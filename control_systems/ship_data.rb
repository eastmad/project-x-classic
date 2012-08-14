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
    p "checking blockers"
    obj.blockers.each do | blocker |
      p "consider blocker on #{obj}"
      if blocker[:active] and method(blocker[:check_method]).call(blocker[:to_check])
        p "block engaged #{blocker[:statement]}"
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
     p "Heading #{@headingPoint}"
     SystemsMessage.new("New heading is #{@headingPoint}", SystemNavigation, :info)
  end
  
  def engage      
    raise SystemsMessage.new("I am not aware of any desired heading", SystemNavigation, :info) if @headingPoint.nil?
    raise SystemsMessage.new("Heading is not a planet", SystemNavigation, :info) unless (@headingPoint.body.kind_of? Planet)
    if (@status == :dependent) 
      raise SystemsMessage.new("I can't engage main drive while docked", SystemSecurity, :info)
    end    
      
    #location must be planet in system
    p "heading body #{@headingPoint.body}"
    p "location owner body #{@locationPoint.body.root_body}"
    raise SystemsMessage.new("Cannot head for a planet not in this system", SystemNavigation, :info) unless (@headingPoint.body.owned_by? @locationPoint.body.local_star)
          
    @locationPoint = @headingPoint
    @headingPoint = nil
    @state = :sync 
    SystemsMessage.new("#{DRIVE} engaged", SystemPower, :info)
  end
  
  def approach(target_body)
 
    inside = @locationPoint.body == target_body.owning_body
    p "in approach #{target_body}"    
 
    lps = (@locationPoint.find_linked_location :satellite) + (@locationPoint.find_linked_location :approach)
    raise SystemsMessage.new("#{target_body} not in range of thrusters", SystemNavigation, :info) if (lps.empty? and !inside)
    raise SystemsMessage.new("Cannot approach #{target_body} safely with thrusters", SystemNavigation, :info) if (lps.empty? and inside)
    
    found_lp = lps.find {| lp | p "lps = #{lp.body}";lp.body == target_body || lp.body == target_body.owning_body}
    
    p "exit approach #{found_lp}"
    
    raise SystemsMessage.new("#{target_body} not in range of thrusters", SystemNavigation, :info) if found_lp.nil?
    
    @locationPoint = found_lp
    @status = :rest
    
    SystemsMessage.new("#{THRUSTERS} fired", SystemPower, :info)
  end
  
  def orbit(planet)      
    raise SystemsMessage.new("#{@name} is in orbit around #{planet}", SystemNavigation, :info) if (@status == :sync and @locationPoint == planet.orbitPoint)
    raise SystemsMessage.new("#{@name} is stationary", SystemNavigation, :info) if (@status ==:dependent)
    raise SystemsMessage.new("Cannot establish an orbit around #{planet}", SystemNavigation, :info) unless (planet.kind_of? Planet) 
    
    #location must be planet or there must be a link to orbit
    #state must be at rest
 
    orbit_point = @locationPoint.find_linked_location :orbit
    found_orbit_point = orbit_point.first.body == planet unless orbit_point.empty?
    p "found_orbit_point = #{found_orbit_point}"
    raise SystemsMessage.new("Cannot orbit #{planet} from #{@locationPoint}", SystemNavigation, :info) unless ((planet == @locationPoint.body or found_orbit_point) and @status != :sync)
        
    @status = :sync
    @locationPoint = planet.orbitPoint
        
    SystemsMessage.new("#{@name} in orbit around #{planet}", SystemNavigation, :info)   
  end
  
  def dock(spaceStation)
    raise SystemsMessage.new("#{@name} is already docked", SystemNavigation, :info) if (@status == :dependent)
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
    p "bay = #{bay}"
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
  
  def jump sys
    raise SystemsMessage.new("No Jump pod present", SystemModification, :info) unless @modification.mod_type_present? :pod
    
    SystemsMessage.new("Jumping to #{sys} system.", SystemPower, :info)
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
  
  def contact(con)
    local_body =  @locationPoint.body

    raise SystemsMessage.new("You can only contact a person.", SystemCommunication, :info) unless con.kind_of? Contact    
    raise SystemsMessage.new("We are not close enough to #{con.owning_body}", SystemCommunication, :info) unless (con.owned_by?(local_body) || con.owning_body == local_body || con.owning_body.owning_body == local_body.owning_body) 

    #check @meet.meet_me[name] for an entry
    mes = con.not_interested_string
    if @icontact.contacted? con
      mes = con.already_agreed_meet_string
    else
    
      if @icontact.interested?(con, @trade.cargo)
        mes = con.agreed_meet_string
        @icontact.contact_made(con)
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
          return SystemsMessage.new(mes, SystemCommunication, :info)
        else
          mes = person.already_met_string
        end
      else
        mes = person.not_interested_string
      end
    else
      mes = "Contact #{person} first. It's only polite."
    end
    
    raise SystemsMessage.new(mes, SystemCommunication, :info)
  end


  def land_need_approach?(sgo)
    raise SystemsMessage.new("#{@name} is already stationary", SystemPower, :info) if (@status == :dependent)
    raise SystemsMessage.new("You can only land at a city space port", SystemPower, :info) unless (sgo.kind_of? Planet or sgo.kind_of? City)
    raise SystemsMessage.new("#{@name} is above #{@locationPoint.body} not #{sgo}", SystemPower, :info) if sgo.kind_of? Planet and @locationPoint.body != sgo
    
    lps = (@locationPoint.find_linked_location :land)
    if lps.empty?
         p "can't land - call approach to #{sgo}" 
         return true
    end
    
    false
  end
             
 def land(sgo)
    city_point = @locationPoint.body.available_city(sgo)
    raise SystemsMessage.new("No space ports found", SystemNavigation, :info) if city_point.nil?
   
    @status = :dependent
    @locationPoint = city_point
    
    SystemsMessage.new("Landed at #{city_point.body.name}", SystemPower, :info)  
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