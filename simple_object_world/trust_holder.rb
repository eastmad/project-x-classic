module TrustHolder
  attr_reader :trust_list
   
  private
  
  def add_to_trust_list(trust, obj)   
    @trust_list = [] if @trust_list.nil?

    @trust_list << {:trust => trust, :obj => obj} unless horizon(trust,obj)
  end
  
  def check_trust_list
    @trust_list = [] if @trust_list.nil?

    @trust_list.each do | t |
      next if t[:used]
      
      obj = t[:obj]
      t[:used] = true if horizon(t[:trust], obj)        
    end
  end
  
end
