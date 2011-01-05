class KeystrokeReader
   def self.key_in(k, str)      
      
      state = :empty
      
      if (k == :backspace)
         info "keystroke str='#{str}', length = #{str.length}"
         if (str.length == 0)
            state = :delete
         else
            str.chop!
            state = :typing
         end           
      elsif (k == ' ')
         state = :complete_me         
      elsif (k == "\n" or k == :enter)
         state = :done   
      elsif (k == :f10)
          state = :exit
      else   
         str = str + k
         state = :typing
      end
      
      return {:str => str, :state => state}
   end
end