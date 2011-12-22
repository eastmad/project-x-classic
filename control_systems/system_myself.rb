class SystemMyself < ShipSystem 
  Operation.register_sys(:myself)  

  def self.cursor_str
    "myself:"
  end
  
  def _help(args = nil)
    _status args
  end
  
  def _status(args = nil)
    begin
    
      info "status for #{args}"
      sys = get_system_from_symbol(args.to_sym()) unless args.nil?
      if args.nil?
        ret = "  Status\n\n  #{SystemNavigation.status}"
        sugs = @@ship.suggest
        sugs.each {|sug| ret << "\n  -#{sug}"}
        #all_systems = poop(Operation.find_all_systems)
        #ret = "  #{@@ship.name} has the systems\n  #{all_systems}"
        #ret << "\n  (Type 'status navigation' to get status report for that system)"
        @@rq.enq SystemsMessage.new(ret, SystemMyself, :report)
      else
        para1 = "  #{sys.to_s}"
        para1 << "\n\n  #{sys.status}"
        all_commands = poop(Operation.find_sys_commands(args.to_sym())) 
        para1 << "\n  #{args} recognises the following commands:\n #{all_commands}."
        #para1 << "\n  #{help(sys)}"
        @@rq.enq SystemsMessage.new(para1, SystemMyself, :report)
        sys = SystemNavigation if sys.nil?
      end
      
    
      resp_hash = {:success => true}
    rescue => ex
      info "whoops #{ex}"
      @@rq.enq SystemsMessage.new("Not a system on this ship.", SystemMyself, :response_bad)
      resp_hash = {:success => false}
    end
    
    resp_hash
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
    
  def method_missing (methId, *args)      
    word = methId.id2name
    info "(methId, *args) Call method myself missing:#{word} and #{args.length} "

    ret = word.slice!(0)
    info "is #{word} system?"
    return word if ShipSystem.is_ship_system?(word)
    
    nil  
  end
end
