class SystemLibrary < ShipSystem
    
  Operation.register_sys(:library)
  
  
  def _describe(arg = nil)
      begin
        sgo = ShipSystem.find_sgo_from_name(@obj)
         
        sgo = @@ship.locationPoint.body.root_body if (@obj.nil?)
        
        para1 = "#{sgo}\n\n"
        para1 << sgo.describe
        para1 << "\n- " << sgo.desc
        para1 << "\n- " << sgo.describe_owns
        para1 << "\n\n(Type 'describe Mars' to find information about any catalogued object)" if @obj.nil?
  
        @@rq.enq SystemsMessage.new(para1, SystemLibrary, :report)
        {:success => true, :media => :describe}
      rescue RuntimeError => ex
        resp_hash = {:success => false}
        @@rq.enq ex
        @@rq.enq SystemsMessage.new("No information available", SystemLibrary, :response_bad)
      end
  end
  
  def self.to_s
     "library"
  end
  
  def self.cursor_str
     "library:"
  end
end