class SystemTrade < ShipSystem 
  Operation.register_sys(:trade)  
  attr_accessor :trade_page

  def self.cursor_str
    "trade:"
  end
  
  def self.welcome
  
    para1 = <<-END.gsub(/^ {8}/, '')
      #{@trade_page}
    END
    
    SystemsMessage.new(para1, SystemTrade, :mail)
  end  
  
  def self.prepare_trade_page(station)
    @trade_page = station.trade_page  
  end
  
  def _accept(args = nil)
    begin    
      item = ShipSystem.find_sgo_from_name(@obj)
     
      @@rq.enq @@ship.accept(item)
      @@rq.enq SystemsMessage.new("Accepted contract to find a buyer for #{@obj}", SystemTrade, :response)
      {:success => true, :media => :trade}
    rescue => ex
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot accept.", SystemTrade, :response_bad)
      {:success => false}
    end
  end
  
  def _fulfill(args = nil)
    begin    
     item = ShipSystem.find_sgo_from_name(@obj)

     @@rq.enq @@ship.fulfill(item)
     @@rq.enq SystemsMessage.new("Fulfilled contract to find a source of #{@obj}", SystemTrade, :response)
     {:success => true, :media => :trade}
    rescue => ex
     @@rq.enq ex
     @@rq.enq SystemsMessage.new("Cannot fulfill.", SystemTrade, :response_bad)
     {:success => false}
    end
  end
  
  def to_s
    "Trade"
  end
  
  
  def method_missing (methId, *args)      
    word = methId.id2name
    info "(methId, *args) Call method missing:#{word} and #{args.length} "

    word.slice!(0)
    info "is #{word} proper noun?"
    if ShipSystem.is_proper_noun?(word)
      if (@obj.nil?)
        @obj = ShipSystem.make_proper_noun(word)
      elsif (@subj.nil?)
        @subj = ShipSystem.make_proper_noun(word)
      end
    elsif ShipSystem.is_subject?(word)
      if (@obj.nil?)
        @obj = word
      elsif (@subj.nil?)
        @subj = word
      end
    elsif ShipSystem.is_subject?("#{word} #{@second_obj}")
      
        @obj = "#{word} #{@second_obj}" if (@obj.nil?)
    else
      @second_obj = word
    end
  end
end