class ActionLine

   attr_accessor :line_type, :response_type, :origin
   
   def copy_line other_line
      set_stroke other_line.response_type
      @origin = other_line.origin
      @response_type = other_line.response_type
      
      @line_type.contents[1].replace(other_line.line_type.contents[1])
      if (other_line.response_type == :mail)
        @line_type.contents[0].replace((@origin.nil?)? "": "_____mail from #{@origin.cursor_str}\n")
      else
      	@line_type.contents[0].replace((@origin.nil?)? "": @origin.cursor_str)
      end
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
         @line_type.stroke = rgb(200,200,250)
         @line_type.leading = 2
       else
         @line_type.stroke = rgb(255,255,255)
      end
   
   end
   
end