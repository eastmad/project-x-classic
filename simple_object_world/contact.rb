class Contact < SimpleBody
  attr_reader :org, :title, :details, :gender
  
  def initialize(gender, title, name, desc, org, ownerPoint)
    super(name,desc,ownerPoint.body)
    @gender = gender
    @org = org
    @title = title
    @details = {}
  end
  
  def add_details hash
    @details.merge! hash
  end
  
  def to_s
    "#{@title} #{@name}"
  end
  
  def ppnoun
    (@gender == :m)? "he" : "she"
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
