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
    rescue => ex
      info "whoops #{ex}"
      @@rq.enq SystemsMessage.new("Not a system on this ship.", SystemMyself, :response_bad)
      {:success => false}
    end
  end
  
  def _trade(args = nil)
    :trade
  end

  def _navigation(args = nil)
    :navigation
  end

  def _power(args = nil)
    :power
  end
  
  def _communication(args = nil)
    :communication
  end
  
  def _weapon(args = nil)
    :weapon
  end

  def _library(args = nil)
    :library
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
  
  def _help (args = nil)
  
    args ||= :everyting
 
    para1 = <<-END.gsub(/^ {6}/, '')
      
      You are commanding the small spacecraft #{@@ship.name}. I will help you talk to the other onboard systems.
      
      Try 'suggest' for what you could do next.
      Try 'describe' to find out about big things.
      Try 'summarize' to find out about ship systems.
    END
   
    para1 = <<-END.gsub(/^ {6}/, '') if args == :trade      
      
      You can connect a buyer to a seller.
      When you are on a space station you can
      access the trade channel.
      
      Try 'browse' to list traders and trades.
      Try 'accept wafer cones' to take a consignment
      Try 'give wafer cones' to give a consignment.
    END

    para1 = <<-END.gsub(/^ {6}/, '') if args == :navigation      
      
      To dock with a space station or land on a
      planet approach from a stable orbit.
      
      Try 'orbit Earth'.
      Try 'plot course to Mars'.
      Try 'help power' for more.
    END
    
    para1 = <<-END.gsub(/^ {6}/, '') if args == :power
      
      From a stable orbit you may approach a
      planet or space station.
      
      Try 'approach Earth' to steer
      Try 'land on Houston' to land on a city.
      Try 'engage ' after plotting a course.
      Try 'launch' to leave a planet.
    END
    
    para1 = <<-END.gsub(/^ {6}/, '') if args == :communication
      
      Read mail or check contacts on a city.
      
      Try 'view contacts' to check contacts in a city
      Try 'contact Nordstrum' to contact a contact.
      Try 'meet Nordstrum' to meet after initial contact.
      Try 'read mail'.
    END

    para1 = <<-END.gsub(/^ {6}/, '') if args == :mail
      
      Read current mail, or earlier ones.
      
      Try 'read mail' to read current or unread mail
      Try 'read first' to start reading from first entry.
      Try 'read next' to read next mail.
    END
    
    @@rq.enq SystemsMessage.new(para1, "help with #{args}", :report)
   
    {:success => true}
  end
   
  def self.to_s
    "self aware system"
  end
end
