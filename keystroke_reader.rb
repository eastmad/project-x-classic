class KeystrokeReader
   def self.key_in(k, str)      
      
      state = :empty
      
      if (k == :backspace)
         if (str.length == 0)
            state = :delete
         else
            str.chop!
            state = :typing
         end           
      elsif (k == ' ' || k == :tab)
         state = :complete_me         
      elsif (k == "\n" or k == :enter)
         state = :done   
      elsif (k == :f10 || k == :escape)
          state = :exit
      elsif (k == :f11)
          state = :talk_test   
      else   
         str = str + k
         state = :typing
      end
      
      return {:str => str, :state => state}
   end
end