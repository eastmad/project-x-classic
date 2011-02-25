class SystemTrade < ShipSystem 
  Operation.register_sys(:trade)  
  
  def self.cursor_str
    "trade:"
  end
  
  def _browse(arg = nil)
    begin    
      station = @@ship.locationPoint.body
      raise SystemsMessage.new("No trade channel found", SystemTrade, :response_bad) unless station.kind_of? SpaceStation      
      
      subj = arg || :trades      

      if (sgo = ShipSystem.find_sgo_from_name(arg))
        para1 = sgo.describe      
      elsif (subj == :trader)
        para1 = station.traders_page
      elsif (subj == :trades)
        para1 = station.trades_page
      end  
 
      @@rq.enq SystemsMessage.new(para1, SystemTrade, :report)
      {:success => true, :media => :trade}
    rescue RuntimeError => ex
      resp_hash = {:success => false}
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemNavigation, :response_bad)
    end
  end

  def _trader(args = nil)
    :trader
  end
  
  def _traders(args = nil)
    :trader
  end   
   
  def _trade(args = nil)
    :trades
  end  
   
  def _industries(args = nil)
    :industries
  end  
  
  def _intergalactic(args = nil)
      :intergalactic
  end
   
  def _accept(args = nil)
    begin    
      item = ShipSystem.find_sgo_from_name(@obj)
     
      @@rq.enq @@ship.accept(item)
      @@rq.enq SystemsMessage.new("Accepted consignment of #{@obj}", SystemTrade, :response)
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
     @@rq.enq SystemsMessage.new("Fulfilled request for #{@obj}", SystemTrade, :response)
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
    info "(methId, *args, #{args[0]}) Call method missing:#{word} and #{args.length} "

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