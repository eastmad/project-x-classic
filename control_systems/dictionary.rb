class Dictionary
   @@Words = [
            {:word => :status, :grammar => :short, :sys => :myself},
            {:word => :help, :grammar => :short, :sys => :myself},
            {:word => :manifest, :grammar => :short, :sys => :trade},
            {:word => :cargo, :grammar => :short, :sys => :trade},
            {:word => :people, :grammar => :short, :sys => :communication},
            {:word => :planets, :grammar => :short, :sys => :library},
            {:word => :companies, :grammar => :short, :sys => :trade},
            {:word => :bay, :grammar => :verb, :sys => :trade},
            {:word => :trades, :grammar => :short, :sys => :trade},
            
            {:word => :approach, :grammar => :verb, :sys => :power},
            {:word => :launch, :grammar => :verb, :sys => :power},
            {:word => :land, :grammar => :verb, :sys => :power, :following => :self},
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
            {:word => :contact, :grammar => :verb, :sys => :communication},
            {:word => :meet, :grammar => :verb, :sys => :communication},
            {:word => :mail, :grammar => :noun, :sys => :communication},
            {:word => :describe, :grammar => :verb, :sys => :library},
          
            {:word => :release, :grammar => :verb, :sys => :security},
            {:word => :gate, :grammar => :noun, :sys => :navigation},
            {:word => :probe, :grammar => :noun, :sys => :navigation},
            {:word => :course, :grammar => :noun, :sys => :navigation},
            {:word => :cannon, :grammar => :noun, :sys => :weaponry},
            {:word => :torpedo, :grammar => :noun, :sys => :weaponry},
            {:word => :shield, :grammar => :noun, :sys => :modification},
            {:word => :jump, :grammar => :noun, :sys => :modification},
            {:word => :message, :grammar => :noun, :sys => :communication},
            {:word => :vessel, :grammar => :noun, :sys => :weaponry},
            {:word => :drive, :grammar => :noun, :sys => :power},
            {:word => :consignment, :grammar => :noun, :sys => :trade},
            
            {:word => :for, :grammar => :preposition},
            {:word => :at, :grammar => :preposition},
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
            
            {:word => :red, :grammar => :adjective},
            {:word => :orange, :grammar => :adjective},
            {:word => :yellow, :grammar => :adjective},
            {:word => :green, :grammar => :adjective},
            {:word => :blue, :grammar => :adjective},
            {:word => :indigo, :grammar => :adjective},
            {:word => :violet, :grammar => :adjective},
            
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
   
   def self.all_matching_words(str, filter, context)              
     res = []
     @@Words.each do |k|
       if (k[:word].to_s.match("^#{str}") and filter.include?(k[:grammar]) and 
           (context.nil? or k[:sys].nil? or k[:sys] == context)) 
         res << k
       end
     end
     
      str = str.downcase
      @@Words.each do |k|
       if (k[:word].to_s.downcase.match("^#{str}") and filter.include?(k[:grammar]) and 
           (context.nil? or k[:sys].nil? or k[:sys] == context)) 
         res << k
       end
      end
           
     return res   
   end
   
   def self.filter_with_letter(words, letter)
      res = []
      words.each do |word|
         if word[:word].to_s.include? letter
            res << word
         end
      end
      
      return res if res.size > 0
      words
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