class SimpleBody

  attr_reader :name, :desc, :owning_body, :boundary_point, :id
  @@outgoing_mail = []
  @@simple_body_ref = {}
  
  def initialize name, desc = "Unknown origin", owner = nil, id = nil
    @name = name
    @desc = desc
    @owning_body = owner
    @visited = false
    unless id.nil?
      raise "Non unique id #{id} - STOP" if @@simple_body_ref.has_key? id.to_sym    
      @@simple_body_ref.merge!({id.to_sym => self})
    end
    
  end
  
  def root_body
    body = self
    until body.owning_body.nil?
       body = body.owning_body
    end
    
    body
  end
  
  #can die here, in theory, so beware
  def local_star
    body = self
    until body.kind_of? Star
       body = body.owning_body
    end
    
    body
  end
  
  def push_message txt, from
    @@outgoing_mail << Mail.new(txt, from) 
  end
 
  def self.get_mail
    @@outgoing_mail
  end
  
  def self.find key
    @@simple_body_ref[key]
  end
  
  def to_s
    @name
  end

end

class Mail
  attr_reader :txt, :from, :read  
    
  def initialize txt, from
    @txt = txt
    @from = from
    @read = false       
  end
  
  def consume
    @read = true
  end
end
