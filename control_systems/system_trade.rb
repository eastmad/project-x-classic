class SystemTrade < ShipSystem 
  Operation.register_sys(:trade)  
  
  def self.cursor_str
    "trade:"
  end

  def _bay(arg = nil)
    begin
      para1 = @@ship.bay(arg)
      para1 << "\n (Type 'bay red' to see details of that cargo)"
      @@rq.enq SystemsMessage.new(para1, "Cargo bay manifest", :report)

      {:success => true, :media => :trade}
    rescue RuntimeError => ex
      @@rq.enq ex
      {:success => false}
    end
  end

  def _manifest(arg = nil)
    _bay nil
  end
  
  def _cargo(arg = nil)
    _bay nil
  end
  
  def _torpedoes(arg = nil)
   info "noun exception"
    begin
      @@rq.enq @@ship.load_torpedoes
      {:success => true}
    rescue => ex
      @@rq.enq ex
      {:success => false}
    end
  end
  
  def _trades(arg = nil)
    begin    
      station = @@ship.locationPoint.body
      raise SystemsMessage.new("A trades or services channel is only broadcast from space stations.", SystemTrade, :response_bad) unless station.kind_of? SpaceStation      
      
      subj = arg || :trades      

      if (sgo = ShipSystem.find_sgo_from_name(arg))
        para1 = sgo.describe
        para1 << "\n#{sgo.desc}"
      elsif (subj == :trader)
        para1 = station.traders_page
      elsif (subj == :trades)
        para1 = station.trades_page
      end  
 
      @@rq.enq SystemsMessage.new(para1, SystemTrade, :report)
      
      resp_hash = {:success => true, :media => :trade}
    rescue RuntimeError
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("No information available", SystemNavigation, :response_bad)
      resp_hash = {:success => false}
    end
    
    resp_hash
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
  
  def _trading(args = nil)
    :trading
  end
   
  def _load(args = nil)
    begin
      #exception noun
      return args if args.kind_of? Hash
      
      item = ShipSystem.find_sgo_from_name(@obj)
     
      @@rq.enq @@ship.accept(item)
      @@rq.enq SystemsMessage.new("Accepted consignment of #{@obj}", SystemTrade, :response)
      
      resp_hash = {:success => true, :media => :trade}
    rescue => ex
      @@rq.enq ex
      @@rq.enq SystemsMessage.new("Cannot accept.", SystemTrade, :response_bad)
      resp_hash = {:success => false}
    end
    
    resp_hash
  end
  
  def _unload(args = nil)
    begin    
     item = ShipSystem.find_sgo_from_name(@obj)

     @@rq.enq @@ship.give(item)
     @@rq.enq SystemsMessage.new("Fulfilled request for #{@obj}", SystemTrade, :response)
     resp_hash = {:success => true, :media => :trade}
    rescue => ex
     @@rq.enq ex
     @@rq.enq SystemsMessage.new("Cannot fulfill.", SystemTrade, :response_bad)
     resp_hash = {:success => false}
    end
    
    resp_hash
  end
  
  def self.status
    num = @@ship.trade.cargo.size
    consignments = "#{num}"
    consignments = "No" if num == 0 
    para1 = <<-END.gsub(/^ {4}/, '')      
      -#{consignments} consignments in cargo bays.
    END
  end

  def to_s
    "Trade"
  end
  
  def self.to_s
     "trade system"
  end
  
  def method_missing (methId, *args)      
    word = methId.id2name
    #info "(methId, *args, #{args[0]}) Call method missing:#{word} and #{args.length} "

    word.slice!(0)
    info "is #{word} proper noun?"
    if ShipSystem.is_proper_noun?(word)
      if (@obj.nil?)
        @obj = ShipSystem.make_proper_noun(word)
      elsif (@subj.nil?)
        @subj = ShipSystem.make_proper_noun(word)
      end
    elsif ShipSystem.is_item?(word)
      if (@obj.nil?)
        @obj = word
      elsif (@subj.nil?)
        @subj = word
      end
    elsif ShipSystem.is_item?("#{word} #{@second_obj}")
      
        @obj = "#{word} #{@second_obj}" if (@obj.nil?)
    else
      @second_obj = word
    end
  end
end
