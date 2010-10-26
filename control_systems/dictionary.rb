class Dictionary
   @@Words = [ 
            {:word => :fire, :grammar => :verb, :systems => [:weapon]},
            {:word => :compute, :grammar => :verb, :systems => [:navigation]},
            {:word => :launch, :grammar => :verb, :systems => [:weapon, :power]},
            {:word => :engage, :grammar => :verb, :systems => [:power]},
            {:word => :dock, :grammar => :verb, :systems => [:navigation, :power]},
            {:word => :orbit, :grammar => :verb, :systems => [:navigation, :power]},
            {:word => :undock, :grammar => :verb, :systems => [:navigation, :power]},
            {:word => :plot, :grammar => :verb, :systems => [:navigation]},
            {:word => :send, :grammar => :verb, :systems => [:comms]},
            {:word => :describe, :grammar => :verb, :systems => [:library]},
            {:word => :summarize, :grammar => :verb, :systems => [:myself]},
            {:word => :help, :grammar => :verb, :systems => [:myself]},
            {:word => :describe, :grammar => :verb, :systems => [:myself]},                        
            {:word => :gate, :grammar => :noun, :systems => [:navigation]},
            {:word => :probe, :grammar => :noun, :systems => [:navigation, :power]},
            {:word => :course, :grammar => :noun, :systems => [:navigation]},
            {:word => :cannon, :grammar => :noun, :systems => [:weapon]},
            {:word => :planet, :grammar => :noun, :systems => [:navigation]},
            {:word => :torpedo, :grammar => :noun, :systems => [:weapon]},
            {:word => :message, :grammar => :noun, :systems => [:comms]},
            {:word => :vessel, :grammar => :noun, :systems => [:weapon]},
            
            {:word => :for, :grammar => :preposition},
            {:word => :at, :grammar => :preposition},
            {:word => :to, :grammar => :preposition},
            {:word => :from, :grammar => :preposition},
            {:word => :with, :grammar => :preposition},
            
            {:word => :nearest, :grammar => :adjective},
            {:word => :enemy, :grammar => :adjective},
            {:word => :friendly, :grammar => :adjective}
      ]   
      
   def self.matching_word(str)              
      res = nil
      
      @@Words.each do |k|
         if (k[:word].to_s == str) 
            res = k            
         end          
      end
      
      return res   
   end
   
   def self.complete_me(str, filter)
      res = nil
            
      @@Words.each do |k|
        if (k[:word].to_s.match("^#{str}") and filter.include?(k[:grammar])) 
           res = k
        end          
      end
            
      return res   
   end
   
   def self.add_discovered_proper_noun(str, sgo)
      @@Words << {:word => str.to_sym, :grammar => :proper_noun, :systems =>[:navigation], :sgo => sgo}
   end
end
