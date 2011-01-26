class Dictionary
   @@Words = [ 
            {:word => :approach, :grammar => :verb, :systems => [:power]},
            {:word => :compute, :grammar => :verb, :systems => [:navigation]},
            {:word => :land, :grammar => :verb, :systems => [:power], :following => :self},
            {:word => :launch, :grammar => :verb, :systems => [:weapon, :power]},
            {:word => :engage, :grammar => :verb, :systems => [:power], :following => :drive},
            {:word => :orbit, :grammar => :verb, :systems => [:navigation]},
            {:word => :accept, :grammar => :verb, :systems => [:trade]},
            {:word => :fulfill, :grammar => :verb, :systems => [:trade]},
            {:word => :dock, :grammar => :verb, :systems => [:power], :following => :self},
            {:word => :undock, :grammar => :verb, :systems => [:power], :following => :self},
            {:word => :plot, :grammar => :verb, :systems => [:navigation], :following => :course},
            {:word => :send, :grammar => :verb, :systems => [:comms]},
            {:word => :read, :grammar => :verb, :systems => [:comms]},
            {:word => :mail, :grammar => :noun, :systems => [:comms]},
            {:word => :contract, :grammar => :noun, :systems => [:trade]},
            {:word => :page, :grammar => :noun, :systems => [:comms]},
            {:word => :describe, :grammar => :verb, :systems => [:library]},
            {:word => :summarize, :grammar => :verb, :systems => [:myself]},
            {:word => :help, :grammar => :verb, :systems => [:myself]},
            {:word => :describe, :grammar => :verb, :systems => [:myself]},
            {:word => :status, :grammar => :verb, :systems => [:myself]}, 
            {:word => :release, :grammar => :verb, :systems => [:security]},
            {:word => :gate, :grammar => :noun, :systems => [:navigation]},
            {:word => :probe, :grammar => :noun, :systems => [:navigation, :power]},
            {:word => :course, :grammar => :noun, :systems => [:navigation]},
            {:word => :cannon, :grammar => :noun, :systems => [:weapon]},
            {:word => :planet, :grammar => :noun, :systems => [:navigation]},
            {:word => :torpedo, :grammar => :noun, :systems => [:weapon]},
            {:word => :message, :grammar => :noun, :systems => [:comms]},
            {:word => :vessel, :grammar => :noun, :systems => [:weapon]},
            {:word => :drive, :grammar => :noun, :systems => [:power]},
            
            {:word => :for, :grammar => :preposition},
            {:word => :at, :grammar => :preposition},
            {:word => :to, :grammar => :preposition},
            {:word => :from, :grammar => :preposition},
            {:word => :with, :grammar => :preposition},
            
            {:word => :nearest, :grammar => :adjective},
            {:word => :enemy, :grammar => :adjective},
            {:word => :friendly, :grammar => :adjective}
      ]   
      
   @@shipname = "ship"    
      
   def self.matching_word(str)              
     res = nil
      
     @@Words.each do |k|
       if (k[:word].to_s == str)
         info "#{k[:word]}, #{k[:word].to_s}, #{str}"
         res = k           
       end          
     end
      
     return res   
   end
   
   def self.complete_me(str, filter)
     res = nil
     following = nil
            
     @@Words.each do |k|
       if (k[:word].to_s.match("^#{str}") and filter.include?(k[:grammar])) 
         res = k
         k[:following] = @@shipname if k[:following] == :self
       end          
     end
          
     following = matching_word(res[:following].to_s) if res[:following]     
     return res, following   
   end
   
   def self.add_discovered_proper_noun(str, sgo)
     @@shipname = str if sgo.nil?
     @@Words << {:word => str.to_sym, :grammar => :proper_noun, :systems =>[:navigation], :sgo => sgo}
   end

   def self.add_discovered_subject(str, item)
     @@Words << {:word => str.to_sym, :grammar => :subject, :systems =>[:trade], :sgo => item}
   end
   
   def self.add_system_nouns(sys)
     @@Words << {:word => sys, :grammar => :noun, :systems =>[:myself]}
   end
   
end