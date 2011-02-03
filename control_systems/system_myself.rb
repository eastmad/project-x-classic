class SystemMyself < ShipSystem 
  Operation.register_sys(:myself)  


  def self.cursor_str
    "myself:"
  end
  
  def _status(args = nil)
    begin
    
      info "status for #{args}"
      sys = get_system_from_symbol(args) unless args.nil?
      @@rq.enq SystemsMessage.new("Type 'status navigation' to get status report for that system", SystemMyself, :response) if args.nil?
      sys = SystemNavigation if sys.nil?
    
      sys.status
    
      {:success => true}
    rescue
      @@rq.enq SystemsMessage.new("Not a system on this ship.", SystemMyself, :response_bad)
      {:success => false}
    end
  end

  def _suggest(args = nil)
    @@rq.enq @@ship.suggest
    
    {:success => true}
  end 

  def _summarize(args = nil)
    
    begin
      if args.nil?
        all_systems = Operation.find_all_systems.join(", ")
        ret = "#{@@ship.name} has the systems #{all_systems}"
        para1 = <<-END.gsub(/^ {10}/, '')
          #{ret}.
          
          Type 'summarize navigation' to find all commands known to that system.
        END
      else
         all_commands = Operation.find_sys_commands(args).join(", ") 
         para1 = "#{args} recognises the following commands: #{all_commands}."
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
      
      Try 'suggest' for what you could do next.
      Try 'describe' to find out about things.
      Try 'summarize' to find out about ship systems.
    END

    @@rq.enq SystemsMessage.new(para1, SystemMyself, :report)
   
    {:success => true}
  end
   
  def self.to_s
    "self aware system"
  end
end
