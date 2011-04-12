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
  
  def he_or_she
    (@gender == :m)? "he" : "she"
  end
  
  def him_or_her
    (@gender == :m)? "him" : "her"
  end
  
end

class Organisation
  include Trustee
  attr_reader :name, :desc, :visibility
  
  def initialize(name, desc, visibility)
    @name = name
    @desc = desc
    @visibility = visibility
    @messages = {}
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
