class ImplHelp

  def initialize
   @suggestions = [
   {:txt => "You can leave a space station; try 'undock'", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation}},
   {:txt => "You need to be in a stable orbit to approach other bodies; try 'orbit Earth'", 
    :chk => lambda {@body.kind_of? SpaceStation and @band == :outer}},
   {:txt => "To find orbiting satellites, try 'describe Earth'", 
    :chk => lambda {@band == :orbit}},  
   {:txt => "You can enter the atmosphere from orbit; try 'approach Earth'", 
    :chk => lambda {@band == :orbit and @status == :sync}},
   {:txt => "You can approach satellites from orbit; try 'approach TradeMall'", 
    :chk => lambda {@band == :orbit and @status == :sync}},
   {:txt => "You can land on a space port city; try 'land ProjectX'", 
    :chk => lambda {@band == :atmosphere and @body.kind_of? Planet}},
   {:txt => "You can leave a space port; try 'launch'", 
    :chk => lambda {@band == :surface and @body.kind_of? Planet}},
   {:txt => "You can visit another planet; try 'plot course to Mars'", 
    :chk => lambda {@band != :surface}},
   {:txt => "To turn on the inter-planetery drive system; try 'engage drive'", 
    :chk => lambda {@band != :outer}},
   {:txt => "Read the traders channel; try 'browse trades'", 
    :chk => lambda {@body.kind_of? SpaceStation}}
   ]
  end 

  def suggest (loc, status)
    @band = loc.band
    @body = loc.body
    @status = status
    suggestion_txt = "No further suggestions." 
    use_suggestion = @suggestions.find { |suggestion| !(suggestion.key? :done) and suggestion[:chk].call }
    if use_suggestion
      use_suggestion[:done] = :true
      suggestion_txt = use_suggestion[:txt]
    end  
    return suggestion_txt
  end
end  