class LocationLink

  attr_reader :link_types, :locPoint
  
  def initialize(link_types, locPoint)
    @link_types = link_types.dup
    @locPoint = locPoint
  end
  
  def to_s
    "#{@link_types} => #{locPoint.body}"
  end
end