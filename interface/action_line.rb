class ActionLine

   attr_accessor :line_type, :response_type
   
   def copy_line other_line
      @line_type.text = other_line.line_type.text
      set_stroke other_line.response_type
      @response_type = other_line.response_type
   end
   
   def set_stroke flav
   
      case flav   
       when :response
         @line_type.stroke = rgb(150,150,255)
       when :response_bad
         @line_type.stroke = rgb(255,175,175)
       when :warn
         @line_type.stroke = rgb(255,150,150)
       else
         @line_type.stroke = rgb(255,255,255)
      end
   
   end
   
end