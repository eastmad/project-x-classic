class ActionLine

   attr_accessor :line_type, :flavour, :origin, :recent_flag
   
   def set_line message
     @flavour = message.flavour
     set_stroke message.flavour 
     @origin = message.origin
     @recent_flag = message.recent_flag

     @line_type.contents[2].replace(message.make_string)
     spaces = ""
     txt =""
     if (message.flavour == :mail)
       @line_type.contents[1].underline = "single"
       txt = "mail from #{@origin}\n" unless @origin.nil?
       (1..80).each {|d| spaces += ' '}
       spaces = spaces[0,(spaces.size - txt.size)]
     elsif (message.flavour == :report)
       @line_type.contents[1].underline = "single"
       txt = "#{@origin}\n" unless @origin.nil?
       (1..80).each {|d| spaces += ' '}
       spaces = spaces[0,(spaces.size - txt.size)]
     else
      @line_type.contents[1].underline = "none"
      txt = @origin.cursor_str unless @origin.nil?
      if @recent_flag
         @line_type.contents[0].replace("*")
      else
         @line_type.contents[0].replace("")
      end   
      
     end
     
     @line_type.contents[1].replace("#{spaces}#{txt}")
   end  
   
   def not_recent
      @recent_flag = false
   end
   
   def recent
      @recent_flag = true
   end
   
   def make_string
     @line_type.contents[2]
   end
   
   def set_stroke flav
   
      case flav   
       when :response
         @line_type.stroke = rgb(150,150,255)
       when :response_bad
         @line_type.stroke = rgb(255,175,175)
       when :warn
         @line_type.stroke = rgb(255,150,150)
       when :flag
         @line_type.stroke = rgb(200,200,50)  
       when :mail
         @line_type.stroke = rgb(100,200,150)
         @line_type.leading = 2
         #@line_type.fill =
       when :report
         @line_type.stroke = rgb(100,200,150)
         @line_type.leading = 2
       else
         @line_type.stroke = rgb(255,255,255)
      end
   
   end
   
end