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

  def not_interested_string
    "#{self} doesn't want to meet you. You may not have anything #{self.he_or_she} wants."
  end
  
  def already_agreed_meet_string
    res = "#{self} has already agreed to meet you." 
    res += interseted_in_string
    
    res
  end
  
  def already_met_string
    "#{self} has already met with you." 
  end
  
  def agreed_meet_string
    res = "#{self} has agreed to meet you."
    res += interseted_in_string
    res
  end
  
  private
  
  def interseted_in_string
    "#{self.he_or_she.capitalize} is interested in #{Item.detail(@details[:interest])}." if  @details.has_key? :interest
  end
  
end

class Organisation
  include Trustee
  attr_reader :name, :desc, :visibility
  
  @@org_ref = {}
  
  def initialize(name, desc, visibility, id)
    @name = name
    @desc = desc
    @visibility = visibility
    @messages = {}
    @@org_ref.merge!({id.to_sym => self})
  end
  
  def add_message id, message
    @messages[id] = message
  end
  
  def get_message id
    @messages[id.to_sym]
  end
  
  def self.find key
    @@org_ref[key]
  end
  
  def to_s
    @name
  end

end
