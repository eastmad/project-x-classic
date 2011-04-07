class ImplContact
  attr_reader :meet_me
  
  def initialize
    @meet_me = {}
  end
  
    
  #check for the first consignment that matches interest
  #most likely should check for a unique, then rare.
  def check_cargo contact, cargo
    interests = contact.details[:interest]
    
    return true if interests.nil?
    
    cargo.each do | consignment |
      if consignment.item.conditions.include? interests
        @meet_me[contact.name] = consignment
        return true
      end  
    end
    
    false
  end
  
end
