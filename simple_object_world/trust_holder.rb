module TrustHolder
  attr_reader :trust_list
   
  private
  
  def add_to_trust_list(trust, obj, trustee = nil)   
    @trust_list = [] if @trust_list.nil?

    @trust_list << {:trust => trust, :obj => obj, :trustee => trustee} unless horizon(trust,obj,trustee)
  end
  
  def check_trust_list
    @trust_list = [] if @trust_list.nil?

    @trust_list.each do | t |
      next if t[:used]
      
      obj = t[:obj]
      trustee = t[:trustee]
info "Considering trustee #{trustee}"
      t[:used] = true if horizon(t[:trust], obj, trustee)        
    end
  end
  
end
