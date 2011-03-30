module Trustee
  attr_reader :trust_score
  
  def trust_score
    @trust_score = 0 if @trust_score.nil?
    @trust_score
  end
  
  def trust(amount)
    @trust_score = 0 if @trust_score.nil? 
    @trust_score += amount
  end
end