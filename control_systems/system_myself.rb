class SystemMyself < ShipSystem 
  Operation.register_sys(:myself)  

  def self.cursor_str
    "myself:"
  end
  
  def _status(args = nil)
    begin
    
      info "status for #{@subj}"
      sys = get_system_from_symbol(@subj) unless @subj.nil?
      @@rq.enq SystemsMessage.new("Type 'status navigation' to get status report for that system", SystemMyself, :response) if @subj.nil?
      sys = SystemNavigation if sys.nil?
    
      sys.status
    
      {:success => true}
    rescue
      @@rq.enq SystemsMessage.new("Not a system on this ship.", SystemMyself, :response_bad)
      {:success => false}
    end
  end

  def _summarize(args = nil)
    
    begin
      if @subj.nil?
        all_systems = Operation.find_all_systems.join(", ")
        ret = "#{@@ship.name} has the systems #{all_systems}"
        para1 = <<-END.gsub(/^ {10}/, '')
          #{ret}.
          
          Type 'summarize navigation' to find all commands known to that system.
        END
      else
         all_commands = Operation.find_sys_commands(@subj).join(", ") 
         para1 = "#{@subj} recognises the following commands: #{all_commands}."
      end
      

      resp_hash = {:success => true, :media => :summarize}
      @@rq.enq SystemsMessage.new(para1, SystemMyself, :report)
    rescue RuntimeError => ex          
      resp_hash = {:success => false}
      @@rq.enq SystemsMessage.new("Not a system on this ship.", SystemMyself, :response_bad)
    end      
         
    return resp_hash
  end
   
  def _help
 
    para1 = <<-END.gsub(/^ {6}/, '')
      You are commanding the small spacecraft #{@@ship.name}. I will help you talk to the other onboard systems.
      
      Type 'summarize' to list all online systems.
      Type 'describe' to find information about stars, palnets and satellites.
    END

    @@rq.enq SystemsMessage.new(para1, SystemMyself, :report)
   
    {:success => true}
  end
   
  def self.to_s
    "self aware system"
  end
end
