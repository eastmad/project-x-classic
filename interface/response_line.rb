class ResponseLine

   attr_accessor :cursor, :text, :flavour, :origin, :recent_flag
   
   def set_line message
     @flavour = message.flavour
     @origin = message.origin
     @recent_flag = message.recent_flag


     @text = message.make_string
     spaces = ""
     txt =""
     if (message.flavour == :mail)
       txt = "mail from #{@origin}\n" unless @origin.nil?
       (1..80).each {|d| spaces += ' '}
       spaces = spaces[0,(spaces.size - txt.size)]
     elsif (message.flavour == :report)
       txt = "#{@origin}\n" unless @origin.nil?
       (1..80).each {|d| spaces += ' '}
       spaces = spaces[0,(spaces.size - txt.size)]
     else
      txt = @origin.cursor_str unless @origin.nil?      
     end
     
     @cursor = "#{spaces}#{txt}"
   end  
   
   def not_recent
      @recent_flag = false
   end
   
   def recent
      @recent_flag = true
   end
     
   def make_string
     @text
   end  
end