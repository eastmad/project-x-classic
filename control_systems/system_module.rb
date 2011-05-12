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
  
  def self.to_s
    "modification system"
  end
 
  def self.cursor_str
      "modules:"
  end
  
  def self.status
    para1 = <<-END.gsub(/^ {4}/, '')
      Modification status
      -#{@@ship.modification.mods.size} modules installed.
    END
    @@rq.enq SystemsMessage.new(para1, SystemModification, :response)
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