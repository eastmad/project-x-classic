class MiniMap
  attr_reader :locPoint, :top_left, :current_left, :opt_left;
  
  def initialize (top_left, current_left, option_left)
    @top_left = top_left
    @current_left = current_left
    @opt_left = option_left
  end
  
  def set_location_point locPoint
    raise "Not a locationPoint" unless locPoint.kind_of?(LocationPoint)
    
    @locPoint = locPoint
  end
  
  def top_level
    {:name => @locPoint.body.owning_body.name, :image => gif_map(@locPoint.body.owning_body), :size => size_map(@locPoint.body.owning_body), :left => @top_left}
  end
  
  def current_level
    {:name => @locPoint.body.name, :image => gif_map(@locPoint.body),  :size => size_map(@locPoint.body), :left => @current_left}
  end
  
  def option_level
    return [{:name => "", :image => "gifs/blank_icon.gif", :size => {:width => 0,:height => 0}}] unless @locPoint.body.respond_to? :owns
    lps = @locPoint.body.owns
    lps = @locPoint.find_linked_location(:city) if @locPoint.band == :atmosphere
     
    ret = []
    
    lps.each {|lp|
      ret << {:name => lp.body.name, :image => gif_map(lp.body), :size => size_map(lp.body),:left => @opt_left}
    }
    
    ret
  end
  
  private
  
  def size_map body
    if body.kind_of? Star
      return {:width => 60, :height =>64}
    elsif body.kind_of? SmallStructure
      return {:width => 15, :height =>16}
    else
      return {:width => 30, :height => 32}
    end
  end
  
  def gif_map body
    name =  body.class.name
    
    name.downcase!
    
    return "gifs/#{name}_icon.gif"
  end
end
