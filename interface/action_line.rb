class ActionLine

   attr_accessor :line_type, :flavour, :origin
   
   def set_line message
     @flavour = message.flavour
     set_stroke message.flavour 
     @origin = message.origin
     @line_type.contents[1].replace(message.make_string)
     if (message.flavour == :mail)
       @line_type.contents[0].underline = "single"
       @line_type.contents[0].replace((@origin.nil?)? "": "                   mail from #{@origin.cursor_str}\n")  
     elsif (message.flavour == :report)
       @line_type.contents[0].underline = "single"
       @line_type.contents[0].replace((@origin.nil?)? "": "                     #{@origin.to_s}\n")    
     else
       @line_type.contents[0].underline = "none"
       @line_type.contents[0].replace((@origin.nil?)? "": @origin.cursor_str)  
     end  
   end  
   
   def make_string
     line_type.contents[1]
   end
   
   def set_stroke flav
   
      case flav   
       when :response
         @line_type.stroke = rgb(150,150,255)
       when :response_bad
         @line_type.stroke = rgb(255,175,175)
       when :warn
         @line_type.stroke = rgb(255,150,150)
       when :mail
         @line_type.stroke = rgb(180,180,250)
         @line_type.leading = 2
       else
         @line_type.stroke = rgb(255,255,255)
      end
   
   end
   
end