class GrammarTree
   @@grammars = [
      {:name => :start_grammar,:grammar => :nil,      :branches => [:verb] },
      {:name => :verb1,       :grammar => :verb,      :branches => [:noun, :proper_noun, :adjective]},
      {:name => :adjective1,  :grammar => :adjective, :branches => [:noun, :proper_noun]}, 
      {:name => :proper_noun1,:grammar => :proper_noun,:branches=> [:preposition, :end_grammar]},
      {:name => :noun1,       :grammar => :noun,      :branches=> [:preposition, :end_grammar]},      
      {:name => :preposition1,:grammar => :preposition,:branches=> [:noun, :proper_noun, :adjective]},
      {:name => :adjective2,  :grammar => :adjective, :branches  => [:noun, :proper_noun]}, 
      {:name => :proper_noun2, :grammar => :proper_noun, :branches =>[:end_grammar]},
      {:name => :noun2,        :grammar => :noun, :branches =>[:end_grammar]},
              ]
   
   
      
              
   #plot course to nearest starbase           
   #describe Earth
   #stop engines
   #drop all pods
   #cool pod 5
   #launch probe
   
   def initialize
      @name_stack = Array.new(6)            #max words
      @name_stack << :start_grammar
   end


   def set_grammar(word)
      info "set grammer for #{word}"
      last_name = @name_stack.last
      info "last name was #{last_name}"
      
      pos = 0
      seen_last_name = false
      while (pos < @@grammars.length) do
         if (@@grammars[pos][:name] == last_name)
            seen_last_name = true
         end
         if (@@grammars[pos][:grammar] == word and seen_last_name)
            @name_stack << @@grammars[pos][:name]
            info "grammer #{@@grammars[pos][:name]}"
            info "@name_stack #{@name_stack}"
            return true
         end
         pos += 1         
      end
      
      return false
   end
   
   def next_filter
      info "next filter grammar"
      last_name = @name_stack.last
      info "last name was #{last_name}"
      
      @@grammars.each do | grammar|
         if grammar[:name] == last_name
            info "selected was #{grammar[:branches]}"
            return grammar[:branches]
         end
      end      
   end
   
   def undo_grammar
      @name_stack.pop
   end     
   
   def reset_grammar
      @name_stack.clear
      @name_stack << :start_grammar
   end
                 
end