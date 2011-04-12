class ImplWeapon

  attr_reader :torpedoes

  def initialize max
    @torpedoes = []
    @max_torpedoes = max
  end
  
  def load_torpedo munition_class
    remove_these = @torpedoes.select do |torp|
      torp.yield < munition_class.yield
    end
    
    remove_these.each do |torp|
      @torpedoes.delete torp
    end
    
    while @torpedoes.size < @max_torpedoes
      @torpedoes << munition_class.new
    end
  end

  def destroy target
    raise "Not a structure this weapon can target" unless target.kind_of? SmallStructure
    raise "Structure has insufficient integrity to target" if target.status == :destroyed 
    raise "No torpedoes loaded" unless @torpedoes.size > 0
    
    #select torpedo
    torpedo = nil
    @torpedoes.each do |torp|
      torpedo = torp if (torp.yield - target.damage_rating).abs <= 1
    end
  
    raise "No torpedo with appropriate yield loaded" if torpedo.nil?
     
    outcome = torpedo.yield - target.damage_rating
    ind = @torpedoes.index(torpedo)
    @torpedoes.delete_at ind
   
    if outcome >= 0
      target.status = :disabled if outcome == 0
      target.status = :destroyed if outcome > 0
    end
    
    return outcome
  end
  
end
