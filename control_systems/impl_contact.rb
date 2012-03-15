class ImplContact
  def initialize
    @known_contacts = []
    @met_contacts = []
  end
 
  def any_contacts?
    !@known_contacts.nil? 
  end
  
  def contacted?(contact)
    @known_contacts.include?(contact)		
  end
  
  def contact_made(contact)
    @known_contacts << contact 		
  end
  
  def contact_met(contact)
    @met_contacts << contact 		
  end
  
  def met?(contact)
    @met_contacts.include?(contact)		
  end
  
  def interested?(contact, cargo)
  info "6.0 #{contact}"   
    interest = contact.details[:interest]
  info "6.1 #{interest}"  
    return true if interest.nil?
      
    cargo.each do | consignment |
       return true if consignment.item.conditions.include? interest
    end
    
    false 
  end
  
  def find_interesting_consignment(contact, cargo)
    interest = contact.details[:interest]
    return nil if interest.nil?
      
    cargo.each do | consignment |
       return consignment if consignment.item.conditions.include? interest
    end
    
    nil 
  end
end
