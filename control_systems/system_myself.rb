class SystemMyself < ShipSystem 
  Operation.register_sys(:myself)  

  def self.cursor_str
      "Myself"
  end

  def _summarize(args = nil)
    begin
      if @subj.nil?
        all_systems = Operation.find_all_systems.join(", ")
	ret = "#{@@ship.name} has the systems #{all_systems}"
      else
      	all_commands = Operation.find_sys_commands(@subj).join(", ") 
      	ret = "#{@subj} recognises the following commands: #{all_commands}"
      end
      resp_hash = {:str => ret, :success => true}
      @@rq.enq SystemsMessage.new(ret, SystemMyself, :response)
    rescue RuntimeError => ex          
      resp_hash = {:success => false}
      @@rq.enq SystemsMessage.new("Not a system on this ship.", SystemMyself, :response_bad)
    end      
         
    return resp_hash
  end

    
  def initialize
  end
   
  def to_s
      "I'm online"
  end

  def method_missing (methId, *args)      
     word = methId.id2name
     info "(methId, *args) Call method missing:#{word} and #{args.length} "
       
     if ShipSystem.is_proper_noun?(word)
        if (@obj.nil?)
           @obj = word.capitalize
        elsif (@subj.nil?)   
           @subj = word.capitalize
        end 
     else
	 @subj = word.to_sym
     end
  end
end
