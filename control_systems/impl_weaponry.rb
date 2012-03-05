class ImplWeaponry

  attr_reader :torpedoes

  def initialize max
    @torpedoes = []
    @max_torpedoes = max
  end
  
  def load_torpedoes munition_class
    
    unless @torpedoes.empty?
      info "remove old missles"
      remove_these = @torpedoes.select do |torp|
        torp.yield < munition_class.yield
      end
      
      remove_these.each do |torp|
        @torpedoes.delete torp
      end    
    end
    
    torp_loaded = nil
    info "while #{@torpedoes.size} < #{@max_torpedoes}"
    while @torpedoes.size < @max_torpedoes
      torp_loaded = munition_class.new
      @torpedoes << torp_loaded
    end
    info "torp loaded #{torp_loaded}"
    torp_loaded
  end

  def destroy target
    
    #select torpedo
    torpedo = nil
    @torpedoes.each do |torp|
      torpedo = torp if (torp.yield - target.damage_rating).abs <= 1
    end
  
    return -1 if torpedo.nil?
     
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