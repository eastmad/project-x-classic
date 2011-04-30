class CelestialObject < SimpleBody      
   attr_reader :centrePoint, :orbitPoint, :outerPoint, :surfacePoint
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
      @orbitPoint = LocationPoint.new(self, :orbit)
      @outerPoint = LocationPoint.new(self, :outer)      
      
      @centrePoint.add_link([:up],lp2)
      lp2.add_link([:up],@orbitPoint)
      @orbitPoint.add_link([:up], @outerPoint)
      
   end
   
   def planetFactory(name, desc)
      Planet.new(name, desc, @orbitPoint)
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
      @orbitPoint.find_linked_location(:planet)
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
      @atmospherePoint = LocationPoint.new(self, :atmosphere)
      @orbitPoint = LocationPoint.new(self, :orbit)                 
      @atmospherePoint.add_link([:up],@orbitPoint)       
      
      @orbitPoint.add_link([:star], ownerPoint)  
      @orbitPoint.add_link([:approach], @atmospherePoint)
      ownerPoint.add_link([:planet], @orbitPoint)      
   end
   
   def describe
      "#{@name} is a planet orbiting #{@owning_body.name}"
   end
   
   def owns
       @orbitPoint.find_linked_location(:satellite)
   end
   
   def stationFactory(name, desc)
      SpaceStation.new(name, desc, @orbitPoint)
   end
   
   def structureFactory(name, desc, toughness)
      SmallStructure.new(name, desc, @orbitPoint, toughness)
   end
   
   def cityFactory(name, desc)
      City.new(name, desc, @atmospherePoint, @orbitPoint)
   end
  
   
  def describe_contacts
    cities = @atmospherePoint.find_linked_location(:city).collect{|cityPoint| cityPoint.body}
    
    para1 = ""
    cities.each {|city| para1 <<  city.describe_contacts}
  
    para1
  end
   
   def describe_owns 
       ret = "No orbiting bodies"
       satellites = owns.collect{|locPoint| locPoint.body}
       cities = @atmospherePoint.find_linked_location(:city).collect{|cityPoint| cityPoint.body}
       ret = "The orbiting satellites are: #{satellites.join(', ')}" unless satellites.empty? 
       ret << "\n- City ports are: #{cities.join(', ')}" unless cities.empty?
       ret << "\n(Futher information available for any city or satellite)"
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

class SpaceStation < CelestialObject

  def initialize(name, desc, ownerPoint)      
    super(name, desc, ownerPoint.body)

    @centrePoint = LocationPoint.new(self, :centre)   
    @surfacePoint = LocationPoint.new(self, :surface)
    @outerPoint = LocationPoint.new(self, :outer)

    @centrePoint.add_link([:up], @surfacePoint)
    @surfacePoint.add_link([:up, :launch], ownerPoint)
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

  def traderFactory(name, index,  desc)
    Trader.new(name, index, desc, @centrePoint)
  end
  
  def garageFactory(name, index,  desc)
    Garage.new(name, index, desc, @centrePoint)
  end
  
  def describe
    "#{@name} is a satellite of #{@owning_body.name}"
  end

  def describe_owns 
    ret = "No trading or ship services companies"
    traders = @centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    garages = @centrePoint.find_linked_location(:garage).collect{|traderPoint| traderPoint.body}

    ret = "The trading companies are #{traders.join(', ')}" unless traders.empty?
    ret = "Ship services by #{garages.join(', ')}" unless garages.empty?
    ret
  end
  
  def trades_page 
    ret = ""
    traders = @centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    num = 0
    ret << "Consignments to go\n"    
    traders.each do | trader | 
      #ret << "#{trader.to_s}\n"
      num += 1
      trader.trades.each { |trade| ret << "-#{trade.item} (#{trader.name} #{trader.index_name})\n" if trade.trade_type == :source}
    end
    ret << "\nConsignments needed\n"
    traders.each do | trader | 
      #ret << "#{trader.to_s}\n"
      num += 1
      trader.trades.each { |trade| ret << "-#{trade.item} (#{trader.name} #{trader.index_name})\n" if trade.trade_type == :sink}
    end
  
    ret = nil if num == 0  
    
    ret
  end
  
  def services_page 
    ret = ""
    garages = @centrePoint.find_linked_location(:garage).collect{|traderPoint| traderPoint.body}
    num = 0
    ret << "Ship services\n"    
    garages.each do | garage | 
      #ret << "#{trader.to_s}\n"
      num += 1
      garage.services.each { |service| ret << "-#{service.type} (#{garage.name} #{garage.index_name})\n"}
    end
    
    ret = nil if num == 0  
    
    ret
  end
   
  def traders_page 
    ret = ""
    traders = @centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    traders.each do | trader | 
      ret << "\n-#{trader.name} #{trader.index_name}\n#{trader.desc}\n" 
    end
    
    ret
  end
  
  def garages_page 
    ret = ""
    garages = @centrePoint.find_linked_location(:garage).collect{|traderPoint| traderPoint.body}
    garages.each do | garage | 
      ret << "\n-#{garage.name} #{garage.index_name}\n#{garage.desc}\n" 
    end
    
    ret
  end
  
  def welcome
    "The space station #{@name} welcomes your visit. Browse channel open."
  end
end

class SmallStructure < CelestialObject
  include TrustHolder
  attr_reader :damage_rating
  attr_accessor :status
  
  def initialize(name, desc, ownerPoint, toughness)      
    super(name, desc, ownerPoint.body)

    @centrePoint = LocationPoint.new(self, :centre)   
    ownerPoint.add_link([:satellite], @centrePoint)
    @status = :normal
    @damage_rating = toughness
    @death_listener = nil
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
  
  def status= st    
    @status = st
    unless (st == :normal or @death_listener.nil?)
      @death_listener.trust(1)
      push_message("thanks for blowing shit up", @death_listener)
    end  
  end

  def desc
    check_trust_list
    @desc
  end

  def describe
    "#{@name} is a satellite of #{@owning_body.name}"
  end
  
  def describe_owns
    armour = "No amour"
    armour = "Standard amour" if @damage_rating == 2
    armour = "Strong amour and shielding" if @damage_rating >= 2
    armour = "Damaged - no longer functional" if @status == :disabled
    armour = "Totally wrecked - dead" if @status == :destroyed
    "#{armour}"  
  end
  
  def add_updated_desc trust, desc, trustee
    add_to_trust_list trust, desc, trustee 
  end
  
  def add_death_listener trustee
    raise "Not a trustee" unless trustee.kind_of? Trustee
    @death_listener = trustee
  end
  
  private
  
  def horizon trust, desc, org
    if trust <= org.trust_score  
      @desc = desc
      info "#{desc} altered description"
      return true
    end
   
    false
  end
end
