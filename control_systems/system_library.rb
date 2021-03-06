class SystemLibrary < ShipSystem
    
  Operation.register_sys(:library)  
  
  def _describe(arg = nil)
    begin
      sgo = ShipSystem.find_sgo_from_name(arg)
       
      sgo = @@ship.locationPoint.body.local_star if (arg.nil?)
      
      para1 = SystemLibrary.desc sgo
      
      @@rq.enq SystemsMessage.new(para1, SystemLibrary, :report)
      resp_hash = {:success => true, :media => :describe, :sgo => sgo}
    rescue RuntimeError => ex
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemLibrary, :response_bad)
    end
    
    return resp_hash 
  end
  
  def _planets(arg = nil)
    begin
      sgo = @@ship.locationPoint.body.local_star
info "local star = #{sgo}"      
      para1 = SystemLibrary.desc sgo
      
      @@rq.enq SystemsMessage.new(para1, SystemLibrary, :report)
      resp_hash = {:success => true, :media => :describe, :sgo => sgo}
    rescue RuntimeError => ex
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemLibrary, :response_bad)
    end
    
    resp_hash
  end
  
  def _stars(arg = nil)
    begin
      sgo = @@ship.locationPoint.body.root_body
      
      para1 = SystemLibrary.desc sgo
      
      @@rq.enq SystemsMessage.new(para1, SystemLibrary, :report)
      resp_hash = {:success => true, :media => :describe, :sgo => sgo}
    rescue RuntimeError => ex
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemLibrary, :response_bad)
    end
    
    resp_hash
  end

  def self.desc sgo
    raise SystemsMessage.new("That isn't a known galactic object", SystemLibrary, :info) if sgo.nil?
    raise SystemsMessage.new("I only know about large objects", SystemLibrary, :info) unless sgo.respond_to? :describe
    para1  = "  #{sgo}\n\n"
    para1 << "  #{sgo.describe}"
    para1 << "\n  - " << sgo.desc
    para1 << "\n  - " << sgo.describe_owns if sgo.respond_to? :describe_owns
    
    para1
  end
  
  def self.to_s
     "Library system"
  end
  
  def self.cursor_str
     "library:"
  end
end