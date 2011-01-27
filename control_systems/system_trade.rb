class SystemTrade < ShipSystem 
  Operation.register_sys(:trade)  
  
  def self.cursor_str
    "trade:"
  end
  
  def _browse(arg = nil)
    begin    
      station = @@ship.locationPoint.body
      raise SystemsMessage.new("No trade channel found", SystemTrade, :response_bad) unless station.kind_of? SpaceStation      
      
      @subj ||= :contract      
      
      if (@subj == :contract)
      	para1 = station.contracts_page
      elsif	(@subj == :trader)
        para1 = station.traders_page
      end  
 
      @@rq.enq SystemsMessage.new(para1, SystemTrade, :report)
      {:success => true, :media => :trade}
    rescue RuntimeError => ex
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemNavigation, :response_bad)
    end
  end

  def _contract(args = nil)
    @subj = :contract
  end
  
  def _contracts(args = nil)
    @subj = :contract
  end   
  
  def _trader(args = nil)
    @subj = :trader
  end
  
  def _traders(args = nil)
    @subj = :trader
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
  
  def self.to_s
     "trade system"
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