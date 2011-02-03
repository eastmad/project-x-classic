class Dictionary
   @@Words = [ 
            {:word => :approach, :grammar => :verb, :sys => :power},
            {:word => :compute, :grammar => :verb, :sys => :navigation},
            {:word => :land, :grammar => :verb, :sys => :power, :following => :self},
            {:word => :launch, :grammar => :verb, :sys => :power},
            {:word => :engage, :grammar => :verb, :sys => :power, :following => :drive},
            {:word => :orbit, :grammar => :verb, :sys => :navigation},
            {:word => :accept, :grammar => :verb, :sys => :trade},
            {:word => :fulfill, :grammar => :verb, :sys => :trade},
            {:word => :dock, :grammar => :verb, :sys => :power, :following => :self},
            {:word => :undock, :grammar => :verb, :sys => :power, :following => :self},
            {:word => :plot, :grammar => :verb, :sys => :navigation, :following => :course},
            {:word => :send, :grammar => :verb, :sys => :comms},
            {:word => :read, :grammar => :verb, :sys => :comms},
            {:word => :browse, :grammar => :verb, :sys => :trade},           
            {:word => :mail, :grammar => :noun, :sys => :comms},
            {:word => :contract, :grammar => :noun, :sys => :trade},
            {:word => :describe, :grammar => :verb, :sys => :library},
            {:word => :summarize, :grammar => :verb, :sys => :myself},
            {:word => :suggest, :grammar => :verb, :sys => :myself},
            {:word => :help, :grammar => :verb, :sys => :myself},
            {:word => :status, :grammar => :verb, :sys => :myself}, 
            {:word => :release, :grammar => :verb, :sys => :security},
            {:word => :gate, :grammar => :noun, :sys => :navigation},
            {:word => :probe, :grammar => :noun, :sys => :navigation},
            {:word => :course, :grammar => :noun, :sys => :navigation},
            {:word => :cannon, :grammar => :noun, :sys => :weapon},
            {:word => :planet, :grammar => :noun, :sys => :navigation},
            {:word => :torpedo, :grammar => :noun, :sys => :weapon},
            {:word => :message, :grammar => :noun, :sys => :comms},
            {:word => :vessel, :grammar => :noun, :sys => :weapon},
            {:word => :drive, :grammar => :noun, :sys => :power},
            {:word => :traders, :grammar => :noun, :sys => :trade},            
            
            {:word => :for, :grammar => :preposition},
            {:word => :at, :grammar => :preposition},
            {:word => :to, :grammar => :preposition},
            {:word => :from, :grammar => :preposition},
            {:word => :with, :grammar => :preposition},
            
            {:word => :nearest, :grammar => :adjective},
            {:word => :enemy, :grammar => :adjective},
            {:word => :friendly, :grammar => :adjective},
            
            {:word => :Industries, :grammar => :proper_noun, :sys => :trade},
            {:word => :Intergalactic, :grammar => :proper_noun, :sys => :trade}
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
   
   def self.complete_me(str, filter, context)
     res = nil
     following = nil
     
     info "str = #{str}, context = #{context}"
            
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
   
   def self.add_discovered_proper_noun(str, sgo)
     @@shipname = str if sgo.nil?
     @@Words << {:word => str.to_sym, :grammar => :proper_noun, :sgo => sgo}
   end

   def self.add_double_discovered_proper_noun(str, follow, sgo)
     @@Words << {:word => str.to_sym, :grammar => :proper_noun, :sys =>:trade, :following => follow, :sgo => sgo}
   end


   def self.add_discovered_subject(str, item)
     @@Words << {:word => str.to_sym, :grammar => :subject, :sys =>:trade, :sgo => item}
   end
   
   def self.add_system_nouns(sys)
     @@Words << {:word => sys, :grammar => :noun, :sys =>:myself}
   end
   
end