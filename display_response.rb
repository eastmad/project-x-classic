class DisplayResponse
  
   attr_accessor :req_str
   attr_accessor :req_grammar
   
   Maxwords = 6     
   
   def initialize
      @req_str = ""
      @req_grammar = :none
      @current_word = 0
      @complete_words= Array.new(Maxwords)
   end
   
   def add_req
      @complete_words[@current_word] = {:word => @req_str, :grammar => @req_grammar}
      @req_str = ""
      @req_grammar = :none
      @current_word += 1
   end   
   
   def remove_req paras
      paras[@current_word].replace ""
      
      if @current_word == 0
         clear paras
         return true
      end
      
      @current_word -= 1
      @req_grammar = @complete_words[@current_word][:grammar]
      @req_str = @complete_words[@current_word][:word].to_s            
      info "Delete: current words = #{@current_word}, str=#{@req_str}, gr=#{@req_grammar}"
      return false
   end
   
   def fullCommand
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
         para.replace "" if (!para.nil?)                     
      end
   end   
   
   #def replace_req parag1, parag2, parag3
   def replace_req paras
      #paras[0].replace "#{@req_str}_"
      i = 0
      while(i < @current_word) do         
         paras[i].replace "#{@complete_words[i][:word]} "                       
         if (@complete_words[i][:grammar] == :none)
            paras[i].stroke = rgb(200,50,50)
         elsif (@complete_words[i][:grammar] == :proper_noun)
            paras[i].stroke = rgb(150,255,150)
         elsif (@complete_words[i][:grammar] == :item)
            paras[i].stroke = rgb(150,150,255)   
         else
            paras[i].stroke = rgb(255,255,100)
         end
         i += 1         
      end
      paras[i].replace "#{@req_str}_"
      paras[i].stroke = rgb(255,255,255)
   end
end