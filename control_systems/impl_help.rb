class ImplHelp

  def initialize
   @suggestions = [
   {:txt => "'trading' or 'services' to see what's on offer", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation and !@body.traders_page.empty?}},
   {:txt => "'load' or 'unload' to move consignments", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation and !@body.traders_page.empty?}},
   {:txt => "'cargo' to see what consignments you hold", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation and !@body.traders_page.empty?}},
   {:txt => "'load' torpedoes or 'install' components", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation and !@body.garages_page.empty?}},
   {:txt => "'undock' to leave a space station", 
    :chk => lambda {@status == :dependent and @body.kind_of? SpaceStation}},
   {:txt => "To enter a space station, 'dock'", 
    :chk => lambda {@band == :outer and @body.kind_of? SpaceStation}},
   {:txt => "'destroy' to damage a structure", 
    :chk => lambda {@body.kind_of? SmallStructure}},
   {:txt => "'plot course' to a planet, then 'engage' drives", 
    :chk => lambda {@band == :orbit}},
   {:txt => "'jump' to use gate", 
    :chk => lambda {@body.kind_of? JumpGate}},
   {:txt => "'describe' to consult library", 
    :chk => lambda {@band == :orbit}},
   {:txt => "'approach' to go towards a planet or satellite", 
    :chk => lambda {@band == :orbit and @status == :sync}},
   {:txt => "'land' on a space port city", 
    :chk => lambda {@band == :atmosphere and @body.kind_of? Planet}},
   {:txt => "'launch' to leave a space port", 
    :chk => lambda {@band == :surface and @body.kind_of? Planet}},
   {:txt => "'people' to list your local contacts", 
    :chk => lambda {(@band == :surface || @status == :sync) and @body.kind_of? Planet}}
   ]
  end 

  def suggest (loc, status)
    @band = loc.band
    @body = loc.body
    @status = status
    use_suggestions = @suggestions.select { |suggestion| suggestion[:chk].call }
    
    suggestions_txt = []
    use_suggestions.each {|suggestion| suggestions_txt << suggestion[:txt] if suggestions_txt.size < 4}
    info suggestions_txt
    return suggestions_txt
  end
end  