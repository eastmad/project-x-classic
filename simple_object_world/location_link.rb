class LocationLink

  attr_reader :link_types, :locPoint
  
  def initialize(link_types, locPoint)
   @link_types = link_types.dup
   @locPoint = locPoint
  end  
end