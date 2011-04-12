class ImplContact
  attr_reader :contacts
  
  def initialize
    @contacts = {}
  end
    
  #check for the first consignment that matches interest
  #most likely should check for a unique, then rare.
  def check_cargo contact, cargo
    interests = contact.details[:interest]
    
    return true if interests.nil?
    
    cargo.each do | consignment |
      if consignment.item.conditions.include? interests
        contact_hash = @contacts[contact.name] unless @contacts.empty?
        contact_hash = {} if contact_hash.nil?
        contact_hash[:consignment] = consignment
        @contacts[contact.name] = contact_hash
        return true
      end  
    end
    
    false
  end
  
end
