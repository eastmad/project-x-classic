class MiniMap
  attr_reader :rootBody, :locPoint
  def initialize rootBody
    raise "Not a body" unless rootBody.kind_of?(CelestialObject)
    @rootBody = rootBody
  end
  
  def setLocationPoint locPoint
    raise "Not a locationPoint" unless locPoint.kind_of?(LocationPoint)
    
    @locPoint = locPoint
  end
  
  def topLevel
    {:name => @rootBody.name, :image => "gifs/star_icon.gif" }
  end
  
  def currentLevel
    {:name => @locPoint.body.name, :image => "gifs/planet_icon.gif" }
  end
  
  def optionLevel
    [
      {:name => @locPoint.body.owns[0].body.name, :image => "gifs/sat_icon.gif" },
      {:name => @locPoint.body.owns[1].body.name, :image => "gifs/sat_icon.gif" }
    ]
  end
end
