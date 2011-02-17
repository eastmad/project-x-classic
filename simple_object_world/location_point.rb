class LocationPoint
  attr_reader :body, :band, :description 
  attr_accessor :links
  
  def initialize(body, band)
    @body = body
    @band = band
    @links = []
  end   
  
  def to_s
    "#{body} #{band}"    
  end
  
  def add_link (link_types, locPoint)
     @links << LocationLink.new(link_types, locPoint)
  end
  
  def is_linked? (locPoint, link_type = nil) 
    links.each do |link|     
      if (link_type == nil or link.link_types.include? link_type)
         return true if (locPoint == link.locPoint) 
      end
    end
    
    false
  end  
  
  def has_link_type? link_type
    links.each do |link|
      return true if (link.link_types.include? link_type)
    end
    
    false
  end
  
  def find_linked_location link_type
    
    locpoints = []
    links.each do |link|    
       locpoints << link.locPoint if link.link_types.include? link_type 
    end
    
    locpoints
  end
  
end