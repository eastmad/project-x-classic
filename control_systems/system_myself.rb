class SystemMyself < ShipSystem 
  Operation.register_sys(:myself)  

  def self.cursor_str
    "myself:"
  end
  
  def _help
    _status
  end
  
  def _status(args = nil)
    begin
    
      info "status for #{args}"
      sys = get_system_from_symbol(args.to_sym()) unless args.nil?
      if args.nil?
        all_systems = poop(Operation.find_all_systems)
        ret = "  #{@@ship.name} has the systems\n  #{all_systems}"
        ret << "\n  (Type 'status navigation' to get status report for that system)"
        @@rq.enq SystemsMessage.new(ret, SystemMyself, :report)
      else
        para1 = "  #{sys.to_s}"
        para1 << "\n\n#{sys.status}"
        all_commands = poop(Operation.find_sys_commands(args.to_sym())) 
        para1 << "\n  #{args} recognises the following commands:\n #{all_commands}."
        para1 << "\n #{help(sys)}"
        @@rq.enq SystemsMessage.new(para1, SystemMyself, :report)
        sys = SystemNavigation if sys.nil?
      end
      
    
      {:success => true}
    rescue => ex
      info "whoops #{ex}"
      @@rq.enq SystemsMessage.new("Not a system on this ship.", SystemMyself, :response_bad)
      {:success => false}
    end
  end
  

  def _suggest(args = nil)
    @@rq.enq @@ship.suggest
    
    {:success => true}
  end 
   
  def self.to_s
    "self aware system"
  end
  
  private
  
  def poop array_of_names
    out = "- "
    i = 1
    array_of_names.each { | name|
      
      out << "#{name}, "
      if (i%3 == 0)
        out << "\n  - "
      end
      i += 1
    }
    
    return out
  end
  
  def help (args = nil)
  
    args ||= :everything
 
    para1 = <<-END.gsub(/^ {4}/, '')
      
      You are commanding the small spacecraft #{@@ship.name}. I will help you talk to the other onboard systems.
      
      Try 'suggest' for what you could do next.
      Try 'describe' to find out about big things.
      Try 'summarize' to find out about ship systems.
    END
   
    para1 = <<-END.gsub(/^ {4}/, '') if args == SystemTrade      
      
      You can connect a buyer to a seller.
      When you are on a space station you can
      access the trade channel.
      
      Try 'browse' to list traders and trades.
      Try 'accept wafer cones' to take a consignment
      Try 'give wafer cones' to give a consignment.
    END

    para1 = <<-END.gsub(/^ {4}/, '') if args == SystemNavigation      
      
      To dock with a space station or land on a
      planet approach from a stable orbit.
      
      Try 'orbit Earth'.
      Try 'plot course to Mars'.
      Try 'help power' for more.
    END
    
    para1 = <<-END.gsub(/^ {4}/, '') if args == SystemPower
      
      From a stable orbit you may approach a
      planet or space station.
      
      Try 'approach Earth' to steer
      Try 'land on Houston' to land on a city.
      Try 'engage ' after plotting a course.
      Try 'launch' to leave a planet.
    END
    
    para1 = <<-END.gsub(/^ {4}/, '') if args == SystemCommunication
      
      Read mail or check contacts on a city.
      
      Try 'view contacts' to check contacts in a city
      Try 'contact Nordstrum' to contact a contact.
      Try 'meet Nordstrum' to meet after initial contact.
      Try 'read mail'.
    END

    para1 = <<-END.gsub(/^ {4}/, '') if args == "mail"
      
      Read current mail, or earlier ones.
      
      Try 'read mail' to read current or unread mail
      Try 'read first' to start reading from first entry.
      Try 'read next' to read next mail.
    END
    
    para1
  end
  
  def method_missing (methId, *args)      
    word = methId.id2name
    info "(methId, *args) Call method myself missing:#{word} and #{args.length} "

    ret = word.slice!(0)
    info "is #{word} system?"
    return word if ShipSystem.is_ship_system?(word)
    
    nil  
  end
end
