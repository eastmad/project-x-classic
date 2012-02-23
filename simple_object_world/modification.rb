class Modification
  
  attr_reader :desc
  
  def name
    self.class.name
  end

  def type
    self.class.type
  end
  
end

class JumpPodModule < Modification
  class << self; attr_accessor :name end
  @name = "Jump Pod"
  
  class << self; attr_accessor :type end
  @type = :pod
      
  def initialize
    @desc = "Gate jump now enabled."
  end    
end

class HeatShieldModule < Modification
  class << self; attr_accessor :name end
  @name = "Heat Shield Module"
  
  class << self; attr_accessor :type end
  @type = :shield
      
  def initialize
    @desc = "Excess heat damping now active."
  end    
end

class Torpedo < Modification
    
  class << self; attr_accessor :yield end
  @yield = 1
  class << self; attr_accessor :name end
  @name = "Basic Torpedo"
    
  def initialize
    @desc = "Please use responsibly."
  end  
    
  def yield
    self.class.yield
  end
  
  def self.type
    :torpedo
  end
  
end

class GovTorpedo < Torpedo
    
  @yield = 2
  @name = "Standard issue torpedo"
  
  def initialize
    @desc = "Safety interlock enabled."
  end  
  
end

class HammerheadTorpedo < Torpedo
    
  @yield = 3
  @name = "Hammerhead torpedo"
  
  def initialize
    @desc = "When sorry isn't good enough."
  end  
  
end
