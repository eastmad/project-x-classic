class City < SimpleBody      
   attr_reader :centrePoint
   attr_accessor :links, :contacts
   
   def initialize(name, desc, ownerPoint)      
      super(name, desc, ownerPoint.body)
      @links = []
      @contacts = []
      @trust_list = []
      @trust_score = 0
      
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
      "#{@name} is a city port of #{@owning_body.name}"
   end
   
   def describe_owns
       "No contacts known."
   end
   
   def welcome
     "The city port of #{@name} welcomes your visit."
   end
   
   def add_contact(contact, trust)
     if trust <= @trust_score
       @contacts << contact
     else  
       @trust_list << {:trust => trust, :contact => contact}
     end  
   end 
  
   def to_s
     @name
   end
   
   private
   
   def check_trust_bucket
     @trust_list.each do | t |
       if t[:trust] <= @trust_score
         contact = t[:trade]
         @contacts << contact
         info "#{contact.name} added to contacts"
         push_message thanks(trade), to_s
       end
     end
   end
   
   def thanks trade
     "Contact added"
   end
end


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
      @surfacePoint = LocationPoint.new(self, :surface)
      @atmospherePoint = LocationPoint.new(self, :atmosphere)
      @orbitPoint = LocationPoint.new(self, :orbit)      
            
      @centrePoint.add_link([:up], @surfacePoint)
      @surfacePoint.add_link([:up, :launch], @atmospherePoint)
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
   
   def structureFactory(name, desc)
      SmallStructure.new(name, desc, @orbitPoint)
   end
   
   def cityFactory(name, desc)
      City.new(name, desc, @atmospherePoint)
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

class SpaceStation < CelestialObject
  :private
  def initialize(name, desc, ownerPoint)      
    super(name, desc, ownerPoint.body)

    @centrePoint = LocationPoint.new(self, :centre)   
    @surfacePoint = LocationPoint.new(self, :surface)
    @outerPoint = LocationPoint.new(self, :outer)

    @centrePoint.add_link([:up], @surfacePoint)
    @surfacePoint.add_link([:up, :launch], @outerPoint)
    @outerPoint.add_link([:dock], @surfacePoint)

    @outerPoint.add_link([:planet, :orbit], ownerPoint) 
    ownerPoint.add_link([:satellite], @outerPoint)      
  end
  :public
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
  
  def describe
    "#{@name} is a satellite of #{@owning_body.name}"
  end

  def describe_owns 
    ret = "No trading companies"
    traders = @centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    ret = "The trading companies are #{traders.join(', ')}" unless traders.empty? 
    ret
  end
  
  def trades_page 
    ret = ""
    traders = @centrePoint.find_linked_location(:trader).collect{|traderPoint| traderPoint.body}
    ret << "Consignments to go\n"    
    traders.each do | trader | 
      #ret << "#{trader.to_s}\n"
      trader.trades.each { |trade| ret << "-#{trade.item} (#{trader.name} #{trader.index_name})\n" if trade.trade_type == :source}
    end
    ret << "\nConsignments needed\n"
    traders.each do | trader | 
      #ret << "#{trader.to_s}\n"
      trader.trades.each { |trade| ret << "-#{trade.item} (#{trader.name} #{trader.index_name})\n" if trade.trade_type == :sink}
    end 
    
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
  
  def welcome
    "The trade station #{@name} welcomes your visit. Browse channel open."
  end
end

class SmallStructure < CelestialObject
  attr_reader :damage_rating
  
  def initialize(name, desc, ownerPoint)      
    super(name, desc, ownerPoint.body)

    @centrePoint = LocationPoint.new(self, :centre)   
    ownerPoint.add_link([:satellite], @centrePoint)      
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

  def describe
    "#{@name} is a satellite of #{@owning_body.name}"
  end
  
  def describe_owns 
    "Low armour, and no active shielding"  
  end
end
