class SystemsMessage < RuntimeError
   attr_reader :text, :origin, :flavour, :recent_flag 

   def initialize txt, orig = nil, flav = :info
      @text = txt
      @origin = orig
      @flavour = flav
      @recent_flag = true
   end
   
   def make_string
      #str = origin.cursor_str unless origin.nil?
      str = " #{@text}"
      str
   end
   
   def to_s
      text
   end
end