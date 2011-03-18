class Contact < SimpleBody
  attr_reader :org, :title
  
  def initialize(title, name, desc, org, ownerPoint)
    
    super(name,desc,ownerPoint.body)
    @org = org
    @title = title
  end
  
  def to_s
    "#{@title} #{@name}"
  end
  
end

class Organisation
  attr_reader :name, :desc, :visibility, :trust_score
  
  def initialize(name, desc, visibility)
    @name = name
    @desc = desc
    @visibility = visibility
    @trust_score = 0
    @messages = {}
  end

  def trust(amount)
    info "trust change #{amount} for #{to_s}"
    @trust_score += amount
  end
  
  def add_message id, message
    @messages[id] = message
  end
  
  def get_message id
    @messages[id.to_sym]
  end
  
  def to_s
    @name
  end

end
