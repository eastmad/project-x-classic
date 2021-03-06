class Trade
  attr_reader :trade_type, :item, :origin_trader
  attr_accessor :status
  
  @@trade_types = {:sink => "Need ", :source => "Supplying"}
  
  def initialize(item, trade_type, origin_trader)
    @status = :available
    @status = :unfulfilled if (trade_type == :sink)
    
    @item = item
    @trade_type = trade_type
    @origin_trader = origin_trader
    
  end
  
  def to_s
    "#{@@trade_types[@trade_type]} #{@item} (#{@status.to_s})"
  end
  
  def accept
    Consignment.new(@item, @origin_trader)
  end
  
  def give (consignment)
    raise "Only a sink trade can be fulfilled" unless @trade_type == :sink
    raise "Trade already fulfilled" if @status == :fulfilled
    raise "Wrong item" unless consignment.item == @item 

    @status = :fulfilled
    info "raise trust for consignment owner and receiving trader"
    consignment.origin_trader.owning_org.trust(1)
    @origin_trader.owning_org.trust(1)    
  end
end

class Item
  attr_reader :name, :desc, :item_type, :conditions
  
  @@item_ref = {}
  
  @@details = {
    :alien => "alien technology or artifacts",
    :foodstuff => "foodstuff",
    :illegal => "illegal goods",
    :controlled => "controlled goods"
    }
  
  def initialize(name, desc, item_type, conditions = [], id = nil)
    @name = name
    @desc = desc
    @item_type = item_type
    @conditions =  conditions.dup unless conditions.nil?
    unless id.nil?
      raise "Non unique id #{id} - STOP" if @@item_ref.has_key? id.to_sym    
      @@item_ref.merge!({id.to_sym => self})
    end
  end
  
  def describe
    para1 = "#{to_s} is a #{item_type} trading item."
    para1 << notes
    para1
  end
  
  def notes
    para1 = ""
    para1 << "  - #{@@details[:controlled]}" if conditions.include? :controlled
    para1 << "  - #{@@details[:illegal]}" if conditions.include? :illegal
    para1 << "  - #{@@details[:foodstuff]}" if conditions.include? :foodstuff
    para1 << "  - #{@@details[:alien]}" if conditions.include? :alien
    
    para1
  end
  
  def self.detail key
     @@details[key]
  end
  
  def self.find key
     @@item_ref[key]
  end
  
  def to_s
    @name
  end
end

class Consignment
  attr_reader :item, :origin_trader
  @@unit_map = {:box => "Box of"}
  
  def initialize(item, origin_trader)
    @origin_trader = origin_trader
    @item = item
  end
  
  def to_s
    if @item.item_type == :unique
      "A #{@item.name}"
    else  
      "Box of #{@item.name} (origin: #{@origin_trader})"
    end
  end
end