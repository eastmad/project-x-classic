class MiniMap
  attr_reader :rootBody, :locPoint
  def initialize rootBody
    raise "Not a body" unless rootBody.kind_of?(CelestialObject)
    @rootBody = rootBody
  end
  
  def set_location_point locPoint
    raise "Not a locationPoint" unless locPoint.kind_of?(LocationPoint)
    
    @locPoint = locPoint
  end
  
  def top_level
    {:name => @rootBody.name, :image => gif_map(@rootBody)}
  end
  
  def current_level
    {:name => @locPoint.body.name, :image => gif_map(@locPoint.body) }
  end
  
  def option_level
    lps = @locPoint.body.owns
    lps = @locPoint.find_linked_location(:city) if @locPoint.band == :atmosphere
     
    ret = []
    
    lps.each {|lp|
      ret << {:name => lp.body.name, :image => gif_map(lp.body)}
    }
    
    ret
  end
  
  private
  
  def gif_map body
    name =  body.class.name
    
    name.downcase!
    
    return "gifs/#{name}_icon.gif"
  end
end
