class SystemModification < ShipSystem 
  Operation.register_sys(:modification)
  
  def _install(args = nil)
    begin
      
      raise SystemsMessage.new("Install what?", SystemModification, :response_bad) if args.nil?
      
      mod = args.to_sym
      @@rq.enq @@ship.install(mod)
      resp_hash = {:success => true}
      
    rescue RuntimeError => ex
      @@rq.enq ex
      resp_hash = {:str => ex, :success => false}
    end      
          
    return resp_hash 
  end
  
  def _modifications(arg = nil)
    begin
      para1 = @@ship.all_mod_cons
      @@rq.enq SystemsMessage.new(para1, "Known modifications", :report)
      resp_hash = {:success => true}
    rescue RuntimeError => ex
      @@rq.enq ex
      resp_hash = {:str => ex, :success => false}
    end      
          
    return resp_hash
  end
  
  def _services(arg = nil)
    begin    
      station = @@ship.locationPoint.body
      raise SystemsMessage.new("A trades or services channel is only broadcast from space stations.", SystemTrade, :response_bad) unless station.kind_of? SpaceStation      
      
      subj = arg || :services      

      if (sgo = ShipSystem.find_sgo_from_name(arg))
        para1 = sgo.describe
        para1 << "\n#{sgo.desc}"
      elsif (subj == :garage)
        para1 = station.services_page  
      elsif (subj == :services)
        para1 = station.services_page
      end  
 
        
      @@rq.enq SystemsMessage.new(para1, SystemModification, :report)
      
      {:success => true, :media => :service}
    rescue RuntimeError
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemNavigation, :response_bad)
      {:success => false}
    end
  end

  
  def self.to_s
    "Module management"
  end
 
  def self.cursor_str
      "modules:"
  end
  
  def self.status
    para1 = <<-END.gsub(/^ {4}/, '')
      -#{@@ship.modification.mods.size} modules installed.
    END
  end
  
  private
  
  def method_missing (methId, *args)      
    word = methId.id2name
    info "(methId, *args) Call modification method missing:#{word} and #{args.length} "

    ret = word.slice!(0)
    info "is #{word} system?"
    return word if ShipSystem.is_module?(word)
    
    nil  
  end
  
end