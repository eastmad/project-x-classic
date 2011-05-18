class SystemLibrary < ShipSystem
    
  Operation.register_sys(:library)  
  
  def _describe(arg = nil)
    begin
      sgo = ShipSystem.find_sgo_from_name(arg)
       
      sgo = @@ship.locationPoint.body.root_body if (arg.nil?)
      
      para1 = SystemLibrary.desc sgo
      
      @@rq.enq SystemsMessage.new(para1, SystemLibrary, :report)
      {:success => true, :media => :describe, :sgo => sgo}
    rescue RuntimeError => ex
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemLibrary, :response_bad)
    end
  end

  def self.desc sgo
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