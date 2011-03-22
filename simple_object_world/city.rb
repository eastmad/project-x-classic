class City < SimpleBody      
   attr_reader :centrePoint
   attr_accessor :links
   
   def initialize(name, desc, ownerPoint, exitPoint)      
      super(name, desc, ownerPoint.body)
      @links = []
      @contacts = []
      @trust_list = []
      @visit_triggers = []
      @visited = false
      @new_contact = false
      
      @centrePoint = LocationPoint.new(self, :centre)
      @centrePoint.add_link([:up, :launch], exitPoint)
      ownerPoint.add_link([:city, :land], @centrePoint)
   end      

   def owned_by? body
      return false if @owning_body.nil?
      return true if @owning_body == body 
      
      return @owning_body.owned_by? body 
   end
   
   def contacts
      check_trust_bucket
      @contacts
   end
   
   def status_word(status, band)
      "parked in"
   end
   
   def describe
      "#{@name} is a city port of #{@owning_body.name}"
   end
   
   def describe_owns
      str = "No known contacts"
      str = "Known contacts are #{contacts.join(', ')}" unless contacts.empty?
      if @new_contact
         str << "\n>>UPDATED<<"
         @new_contact = false
      end
      
      str
   end
   
   def welcome
     "The city port of #{@name} welcomes your visit."
   end
   
   def contactFactory(gender, title, name, desc, org, trust)
      contact = Contact.new(gender, title, name, desc, org, @centrePoint)
 
      if trust <= contact.org.trust_score
         @contacts << contact
        Dictionary.add_discovered_proper_noun(contact.name, contact, :comms)
      else  
         @trust_list << {:trust => trust, :contact => contact}
      end
      
      contact
   end
   
   def visit
     first_visit_trigger unless @visited  
     @visited = true
   end
   
   def add_visit_trigger(org, amount, mail = nil)
      @visit_triggers << {:org => org, :amount => amount, :mail => mail}
   end
   
   def to_s
     @name
   end
   
   private
   
   def check_trust_bucket
     @trust_list.each do | t |
       contact = t[:contact]
       if t[:trust] <= contact.org.trust_score  
         @contacts << contact
         Dictionary.add_discovered_proper_noun(contact.name, contact, :comms)
         info "#{contact.name} added to contacts"
         @new_contact = true
         t[:trust] = 1000
       end
     end
   end
   
   def first_visit_trigger
      @visit_triggers.each do | trig |
         trig[:org].trust(trig[:amount])
         info "mail id = #{trig[:mail]}, message #{trig[:org].get_message(trig[:mail])}" unless trig[:mail].nil?
         push_message(trig[:org].get_message(trig[:mail]), trig[:org]) unless trig[:mail].nil?
      end
   end
end
