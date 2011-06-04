class ImplHelp

  def initialize
   @suggestions = [
   {:txt => "This is a trade station; enter 'accept' or 'give' to move consignments", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation and !@body.trades_page.nil?}},
   {:txt => "This is a service station; enter 'load' torpedoes or 'install' components", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation and !@body.services_page.nil?}},
   {:txt => "'undock' to leave a space station", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation}},
   {:txt => "To enter a space station, 'dock'", 
    :chk => lambda {@band == :outer and @body.kind_of? SpaceStation}},
   {:txt => "Enter 'describe Earth' to find orbiting bodies", 
    :chk => lambda {@band == :orbit}},
   {:txt => "'describe Sol' to find orbiting planets", 
    :chk => lambda {@band == :orbit}},
   {:txt => "Enter 'approach' to go towards a planet or satellite", 
    :chk => lambda {@band == :orbit and @status == :sync}},
   {:txt => "You can 'land' on a space port city", 
    :chk => lambda {@band == :atmosphere and @body.kind_of? Planet}},
   {:txt => "'launch' to leave a space port", 
    :chk => lambda {@band == :surface and @body.kind_of? Planet}},
   {:txt => "'plot course' to a planet before engaging drives", 
    :chk => lambda {@band == :orbit}},
   {:txt => "'engage' to turn on inter-planetery drive system", 
    :chk => lambda {@band == :orbit}},
   {:txt => "'browse' to read station information from the trade channel", 
    :chk => lambda {@body.kind_of? SpaceStation and (!@body.trades_page.nil? or !@body.services_page.nil?)}}
   ]
  end 

  def suggest (loc, status)
    @band = loc.band
    @body = loc.body
    @status = status
    use_suggestions = @suggestions.select { |suggestion| suggestion[:chk].call }
    
    suggestions_txt = []
    use_suggestions.each {|suggestion| suggestions_txt <<  suggestion[:txt]}
    info suggestions_txt
    return suggestions_txt
  end
end  