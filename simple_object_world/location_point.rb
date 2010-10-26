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
  
  def add_link (link_type, locPoint)
     @links << LocationLink.new(link_type, locPoint)
  end
  
  def isLinked? (locPoint, link_type = nil) 
    links.each do |link|
      if (link_type == nil or link_type == link.link_type)
         return true if (locPoint == link.locPoint) 
      end
    end
  end  
  
  def findLinkedLocPoint link_type
    
    locpoints = []
    links.each do |link|
       locpoints << link.locPoint if (link_type == link.link_type) 
    end
    
    locpoints
  end
  
  def out
    links.each do |link|
       return link.locPoint if (link.link_type == :up) 
    end      
  end
end