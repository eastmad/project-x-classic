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
         @line_type.stroke = rgb(50,50,200)
       when :warn
         @line_type.stroke = rgb(200,50,50)
       else
         @line_type.stroke = rgb(0,0,0)
      end
   
   end
   
end