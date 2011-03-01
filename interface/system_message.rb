class SystemsMessage < RuntimeError
   attr_reader :text, :origin, :flavour 

   def initialize txt, orig = nil, flav = :info
      @text = txt
      @origin = orig
      @flavour = flav
   end
   
   def make_string
      #str = origin.cursor_str unless origin.nil?
      str = " #{@text}"
      str
   end
end