class Person
  attr_reader :gender, :name, :title, :desc
  @@people = {}
  
  def initialize(gender, title, name, desc)
    @gender = gender
    @title = title
    @name = name
    @desc = desc
    unless name.nil?
      raise "Non unique id #{name} - STOP" if @@people.has_key? name.to_sym    
      @@people.merge!({name.to_sym => self})
    end
  end
  
  def self.find key
    @@people[key]
  end
end

class Contact < SimpleBody
  attr_reader :person, :org, :details
  
  def initialize(person, org, ownerPoint)
    super(person.name,person.desc,ownerPoint.body)
    @person = person
    @org = org
    @details = {}
  end
  
  def add_details hash
    @details.merge! hash
  end
  
  def to_s
    "#{@person.title} #{@person.name}"
  end
  
  def he_or_she
    (@person.gender == :m)? "he" : "she"
  end
  
  def him_or_her
    (@person.gender == :m)? "him" : "her"
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
