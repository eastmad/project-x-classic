class Dictionary
   @@Words = [ 
            {:word => :approach, :grammar => :verb, :sys => :power},
            {:word => :land, :grammar => :verb, :sys => :power, :following => :self},
            {:word => :launch, :grammar => :verb, :sys => :power},
            {:word => :destroy, :grammar => :verb, :sys => :weaponry},
            {:word => :load, :grammar => :verb, :sys => :weaponry},
            {:word => :install, :grammar => :verb, :sys => :modification},                        
            {:word => :engage, :grammar => :verb, :sys => :power, :following => :drive},
            {:word => :orbit, :grammar => :verb, :sys => :navigation},
            {:word => :accept, :grammar => :verb, :sys => :trade},
            {:word => :give, :grammar => :verb, :sys => :trade},
            {:word => :dock, :grammar => :verb, :sys => :power, :following => :self},
            {:word => :undock, :grammar => :verb, :sys => :power, :following => :self},
            {:word => :plot, :grammar => :verb, :sys => :navigation, :following => :course},
            {:word => :send, :grammar => :verb, :sys => :communication},
            {:word => :read, :grammar => :verb, :sys => :communication},
            {:word => :browse, :grammar => :verb, :sys => :trade},
            {:word => :contact, :grammar => :verb, :sys => :communication},
            {:word => :contacts, :grammar => :noun, :sys => :communication},
            {:word => :view, :grammar => :verb, :sys => :communication, :following => :contacts},
            {:word => :meet, :grammar => :verb, :sys => :communication},
            {:word => :mail, :grammar => :noun, :sys => :communication},
            {:word => :describe, :grammar => :verb, :sys => :library},
            {:word => :summarize, :grammar => :verb, :sys => :myself},
            {:word => :suggest, :grammar => :verb, :sys => :myself},
            {:word => :help, :grammar => :verb, :sys => :myself},
            {:word => :status, :grammar => :verb, :sys => :myself}, 
            {:word => :release, :grammar => :verb, :sys => :security},
            {:word => :gate, :grammar => :noun, :sys => :navigation},
            {:word => :probe, :grammar => :noun, :sys => :navigation},
            {:word => :course, :grammar => :noun, :sys => :navigation},
            {:word => :cannon, :grammar => :noun, :sys => :weaponry},
            {:word => :planet, :grammar => :noun, :sys => :navigation},
            {:word => :torpedo, :grammar => :noun, :sys => :weaponry},
            {:word => :shield, :grammar => :noun, :sys => :modification},
            {:word => :jump, :grammar => :noun, :sys => :modification},
            {:word => :message, :grammar => :noun, :sys => :communication},
            {:word => :vessel, :grammar => :noun, :sys => :weaponry},
            {:word => :drive, :grammar => :noun, :sys => :power},
            {:word => :traders, :grammar => :noun, :sys => :trade},
            {:word => :manifest, :grammar => :verb, :sys => :trade},
            {:word => :bay, :grammar => :verb, :sys => :trade},
            {:word => :trade, :grammar => :noun, :sys => :trade},
            {:word => :consignment, :grammar => :noun, :sys => :trade},
            
            {:word => :for, :grammar => :preposition},
            {:word => :at, :grammar => :preposition},
            {:word => :of, :grammar => :preposition},
            {:word => :in, :grammar => :preposition},
            {:word => :to, :grammar => :preposition},
            {:word => :from, :grammar => :preposition},
            {:word => :with, :grammar => :preposition},
            {:word => :on, :grammar => :preposition},
            
            {:word => :nearest, :grammar => :adjective},
            {:word => :previous, :grammar => :adjective},
            {:word => :next, :grammar => :adjective},
            {:word => :enemy, :grammar => :adjective},
            {:word => :friendly, :grammar => :adjective},
            {:word => :first, :grammar => :adjective},
            {:word => :last, :grammar => :adjective},         
            
            {:word => :Industries, :grammar => :proper_noun, :sys => :trade},
            {:word => :Intergalactic, :grammar => :proper_noun, :sys => :trade},
            {:word => :Garages, :grammar => :proper_noun, :sys => :trade},
            {:word => :Trading, :grammar => :proper_noun, :sys => :trade},
      ]   
      
   @@shipname = "ship"    
      
   def self.matching_word(str)              
     res = nil
      
     @@Words.each do |k|
       if (k[:word].to_s == str)
         res = k           
       end          
     end
      
     return res   
   end
   
   def self.complete_me(str, filter, context)
     res = nil
     following = nil
            
     @@Words.each do |k|
       if (k[:word].to_s.match("^#{str}") and filter.include?(k[:grammar]) and 
           (context.nil? or k[:sys].nil? or k[:sys] == context)) 
         res = k
         k[:following] = @@shipname if k[:following] == :self
       end          
     end
          
     following = matching_word(res[:following].to_s) if (res and res[:following])      
     return res, following   
   end
   
   def self.add_discovered_proper_noun(str, sgo, sys = nil)
     @@shipname = str if sgo.nil?
     
     noun = {:word => str.to_sym, :grammar => :proper_noun, :sgo => sgo}
     noun.merge(:sys => sys) unless sys.nil?
      
     @@Words << noun
   end

   def self.add_double_discovered_proper_noun(str, follow, sgo)
     @@Words << {:word => str.to_sym, :grammar => :proper_noun, :sys =>:trade, :following => follow, :sgo => sgo}
   end
   
   def self.add_discovered_item(str, item)
     @@Words << {:word => str.to_sym, :grammar => :item, :sys =>:trade, :sgo => item}
   end
   
   def self.add_system_nouns(sys)
     @@Words << {:word => sys, :grammar => :noun, :sys =>:myself}
   end
   
end