class Contact < SimpleBody
  attr_reader :trust_score, :org
  
  def initialize(name, desc, org, ownerBody)
    super(name,desc,ownerBody)
    @org = org
    @trust_list = []
    @trust_score = 0
  end
end


class Organisation
  attr_reader :name, :desc, :visibility
  
  def initialize(name, desc, visibility)
    @name = name
    @desc = desc
    @visibility = visibility
  end
end
