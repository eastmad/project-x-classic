class AllowedStates  
  attr_accessor :name, :alpha_key, :arrow_key, :space_key, :return_key, :delete_key
  
  def initialize name
    @name = name
    @alpha_key = nil
    @arrow_key = nil
    @space_key = nil
    @return_key = nil
    @delete_key = nil
  end
end

class InputState
  attr_reader :change, :key
  
  def initialize set_state = nil
    @change = false
    
    start_state = AllowedStates.new(:start)
    next_state = AllowedStates.new(:next)
    word_state = AllowedStates.new(:word)
    
    start_state.alpha_key = word_state
    word_state.return_key = start_state
    word_state.alpha_key = word_state
    word_state.delete_key = word_state
    word_state.space_key = next_state
    word_state.arrow_key = word_state
    next_state.return_key = start_state
    next_state.alpha_key = word_state
    next_state.delete_key = word_state
    
    @sm = start_state
    if set_state == :next
      @sm = next_state
    elsif set_state == :word
      @sm = word_state
    end  
    @change = false   
  end
    
  def state
    @sm.name
  end
    
  def change?
    @change
  end
  
  def accept key_code
    @change = false
    if ('A' .. 'z').include? key_code
      return false if @sm.alpha_key.nil?
      @sm = @sm.alpha_key
      @change = true
      @key = :alpha
    elsif key_code == ' '
      return false if @sm.space_key.nil?
      @sm = @sm.space_key
      @change = true
      @key = :space
    elsif key_code == "\n"
      return false if @sm.return_key.nil?
      @sm = @sm.return_key
      @change = true
      @key = :return
    elsif key_code == :backspace
      return false if @sm.delete_key.nil?
      @sm = @sm.delete_key
      @change = true
      @key = :delete
    elsif key_code == :f1
      @key = :f1  
    elsif (key_code == :up || key_code == :left)
      return false if @sm.arrow_key.nil?
      @change = false
      @key = :up
    elsif (key_code == :right || key_code == :down)
      return false if @sm.arrow_key.nil?
      @change = false
      @key = :down
    else
      return false
    end
    
    true   
  end
  

end
