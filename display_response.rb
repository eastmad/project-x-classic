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
   
   def add_req
      @complete_words[@current_word] = {:word => @req_str, :grammar => @req_grammar}
      @req_str = ""
      @req_grammar = :none
      @current_word += 1
   end   
   
   def remove_req paras
      info "current word = #{@current_word}"
      paras[@current_word].contents[1].replace ""
      paras[@current_word].contents[0].replace ""
      
      if @current_word == 0
         clear paras
         return true
      end
      
      @current_word -= 1
      @req_grammar = @complete_words[@current_word][:grammar]
      #@req_str = @complete_words[@current_word][:word].to_s
      @req_str = ""
      @complete_words[@current_word][:word] = @req_str
      info "leaving remove_req"
      return false
   end
   
   def clear_req paras
      paras[@current_word].contents[1].replace "_"
      paras[@current_word].contents[0].replace "_"
      
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
   
   def clear paras
      @complete_words.clear
      @req_str = ""
      @req_grammar = :none
      @current_word = 0
      
      paras.each do | para |
         para.contents[1].replace "" if (!para.nil?)
         para.contents[0].replace "" if (!para.nil?)
      end
      
      paras[0].contents[1].replace "_"
      paras[0].contents[0].replace ""
      paras[0].stroke = rgb(255,255,255)
   end   
   
   #def replace_req parag1, parag2, parag3
   def replace_req paras
      #paras[0].replace "#{@req_str}_"
      i = 0
      while(i < @current_word) do         
         paras[i].contents[1].replace "#{@complete_words[i][:word]} "
         paras[i].contents[0].replace ""
         if (@complete_words[i][:grammar] == :none)
            paras[i].stroke = rgb(200,50,50)
         elsif (@complete_words[i][:grammar] == :short)
            paras[i].stroke = rgb(255,200,150)            
         elsif (@complete_words[i][:grammar] == :proper_noun)
            paras[i].stroke = rgb(150,255,150)
         elsif (@complete_words[i][:grammar] == :item)
            paras[i].stroke = rgb(150,150,255)   
         else
            paras[i].stroke = rgb(255,255,100)
         end
         i += 1         
      end
      fi = @req_str[0...@typed.size]
      fi = "" if fi.nil?
      sec = "#{@req_str[@typed.size..-1]}_"
      sec = "" if sec.nil?

      paras[i].contents[1].replace sec
      paras[i].contents[0].replace fi
      #paras[i].stroke = rgb(255,255,255)


      if (@req_grammar == :none)
            paras[i].stroke = rgb(200,50,50)
         elsif (@req_grammar == :short)
            paras[i].stroke = rgb(255,200,150)            
         elsif (@req_grammar == :proper_noun)
            paras[i].stroke = rgb(150,255,150)
         elsif (@req_grammar == :item)
            paras[i].stroke = rgb(150,150,255)   
         else
            paras[i].stroke = rgb(255,255,100)
         end
   end
end