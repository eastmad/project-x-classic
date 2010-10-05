class LocationLink

  attr_reader :link_type, :locPoint
  
  def initialize(link_type, locPoint)
   @link_type = link_type
   @locPoint = locPoint
  end  
end