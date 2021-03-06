class City < SimpleBody
  include TrustHolder
  attr_reader :centrePoint
  attr_accessor :links
  
  def initialize(name, desc, ownerPoint, exitPoint)      
    super(name, desc, ownerPoint.body, name.to_sym)
 
    @links = []
    @contacts = []
    @visit_triggers = []
    @new_contact = false
    
    @centrePoint = LocationPoint.new(self, :centre)
    @centrePoint.add_link([:up, :launch], exitPoint)
    ownerPoint.add_link([:city, :land], @centrePoint)
  end     
  
  def contacts
     check_trust_list
     @contacts
  end
  
  def status_word(status, band)
     "parked in"
  end
  
  def describe
     "#{@name} is a city port of #{@owning_body.name}"
  end
  
  def describe_owns 
    "\n(Type 'people' to see who you know in a city)"
  end
   
  def describe_contacts
     con = contacts
     para1 = ""
     con.each do | contact |
        para1 << "#{contact}; #{@name} - #{contact.desc}" 
     end
     
     if @new_contact
       para1 << "\n>>UPDATED<<"
       @new_contact = false
     end
     
     para1
  end
    
  def welcome
    "The city port of #{@name} welcomes your visit."
  end
  
  def contactFactory(person, org, trust)
     contact = Contact.new(person, org, @centrePoint)

     add_to_trust_list(trust,contact,org)
     
     contact
  end
  
  def visit
    first_time = !@visited
    
    first_visit_trigger if first_time  
    @visited = true
    
    first_time
  end
  
  def add_visit_trigger(org, amount, mail = nil)
     @visit_triggers << {:org => org, :amount => amount, :mail => mail}
  end
  
  def to_s
    @name
  end
  
  private
   
  def horizon trust, contact, org
    if trust <= org.trust_score  
      @contacts << contact
      Dictionary.add_discovered_proper_noun(contact.name, contact,:communication)
      push_message("New contact #{contact} has registered #{contact.his_or_her} details.")
      info "#{contact.name} added to contacts"
      @new_contact = true if trust > 0
      return true
    end
   
    false
  end
   
  def first_visit_trigger
     @visit_triggers.each do | trig |
        trig[:org].trust(trig[:amount])
        push_mail(trig[:org].get_message(trig[:mail]), trig[:org]) unless trig[:mail].nil?
        check_trust_list
     end
  end
end
