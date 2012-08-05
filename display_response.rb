class DisplayResponse
  
   attr_accessor :req_str
   attr_accessor :req_grammar
   attr_accessor :script_command
   attr_accessor :typed
   
   Maxwords = 6     
   
   def initialize
      @req_str = ""
      @req_grammar = :none
      @current_word = 0
      @complete_words= Array.new(Maxwords)
      @typed = ""
   end
   
   def add_req civ
      @complete_words[@current_word] = {:word => @req_str, :grammar => @req_grammar}
      @req_str = ""
      @req_grammar = :none
      @current_word += 1
      
      civ.complete_words << [@req_grammer, @req_str]
   end   
   
   def remove_req civ
      
      p "current word = #{@current_word}"
      civ.active_word_part = [:white, ""]
      #paras[@current_word].contents[1].replace ""
      #paras[@current_word].contents[0].replace ""
      
      if @current_word == 0
         clear civ
         return true
      end
      
      @current_word -= 1
      @req_grammar = @complete_words[@current_word][:grammar]
      #@req_str = @complete_words[@current_word][:word].to_s
      @req_str = ""
      @complete_words[@current_word][:word] = @req_str
      p "leaving remove_req"
      return false
   end
   
   def clear_req civ
      civ.active_word_part = [:white, ""]
      #paras[@current_word].contents[1].replace "_"
      #paras[@current_word].contents[0].replace "_"
      
      @req_str = ""
      return false
   end
   
   def fullCommand
      return @script_command if !@script_command.nil?
      fc = ""
      i = 0
      while(i < @current_word) do         
        fc += "#{@complete_words[i][:word]} "                       
        i += 1         
      end
      fc += "#{@req_str}"      
   end
   
   def clear civ
      @complete_words.clear
      @req_str = ""
      @req_grammar = :none
      @current_word = 0
      
      civ.complete_words.each do | word |
        word = [:white, ""]
      end
      
      civ.active_word_part = [:white, ""]
   end   
   
   #def replace_req parag1, parag2, parag3
   def replace_req civ
      #paras[0].replace "#{@req_str}_"
      #civ.active_word_part = [:white, "#{@req_str}_"]
      i = 0
      while(i < @current_word) do         
         civ.complete_words[i][1] = "#{@complete_words[i][:word]} "
         civ.complete_words[i][0] = @complete_words[i][:grammar]
         i += 1         
      end
      fi = @req_str[0...@typed.size]
      #fi = @typed
      fi = "" if fi.nil?
      sec = @req_str
      sec = "" if sec.nil?
   
      civ.suggestion = [@req_grammar, sec]
      civ.active_word_part = [@req_grammar, fi ]
      #paras[i].contents[1].replace sec
      #paras[i].contents[0].replace fi

   end
end