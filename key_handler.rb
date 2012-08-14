class KeyHandler
  
  def initialize
    @key_input_state = InputState.new
    @resps = []
    @pos = 0
    @word_building = ""
    @dr = DisplayResponse.new 
    @gr = GrammarTree.new
    @civ = nil
    @rq = nil
  end

  def debug   ret
    p "ret = #{ret}"
    if @key_input_state.accept ret
      key = @key_input_state.key
      state = @key_input_state.state
      
      p " key = #{key}, state = #{state}"
    end
  end
  
  def set_civ(civ)
    @civ = civ
  end
  
  def set_rq(rq)
    @rq = rq
  end
  
  def set_ship(ship)
    @ship = ship
  end
  
  def reset     
    @dr.clear @civ            
    @state = :empty
    @gr.reset_grammar()
    @civ.key_hints = :start 
  end 

  def process k
    p "ret = #{k}"
    return unless @key_input_state.accept k
    @key = @key_input_state.key
    @state = @key_input_state.state
    @civ.key_hints = @state
        
    if (@key == :down)
      @pos += 1
      @pos = 0 if @pos >= @resps.size
      if @resps.size > @pos
        @dr.req_str = @resps[@pos][:word].to_s 
        @dr.req_grammar = @resps[@pos][:grammar]
      end  
      #@word_building = ""
    elsif (@key == :up)
      @pos -= 1
      @pos = @resps.size - 1 if @pos < 0
      if @resps.size > 0
        @dr.req_str = @resps[@pos][:word].to_s 
        @dr.req_grammar = @resps[@pos][:grammar]
      end
      #@word_building = ""
    elsif (@key == :alpha)
      if @dr.req_str.empty?
        @dr.req_str = k
        @word_building = k
        @dr.typed = k
        @resps = Dictionary.all_matching_words(@dr.req_str, @gr.next_filter, @gr.context)
      else
        @word_building += k
        @dr.typed = @word_building
        p "typed #{@dr.typed}"
        @resps = Dictionary.filter_with_substring(@resps, @word_building)
      end
      if @resps.size > 0
        @dr.req_str = @resps.first[:word].to_s
        @dr.req_grammar = @resps.first[:grammar]
      end  
      @pos = 0
    end           

    if (@key == :exit)
      goodbye()
    end
      
    if (@key == :talk_test)
      talk_screen :war
    end

    if (@key == :delete)
      p "req str to delete >#{@dr.req_str}<" 
      if @dr.req_str.length > 1
       p "clear_req >#{@dr.req_str}<"  
       @dr.clear_req @civ
      else
       p "remove_req >#{@dr.req_str}<"  
       @gr.undo_grammar
       needs_reset = @dr.remove_req @civ            
       #@dr.replace_req @civ
       p "reset? >#{needs_reset}<"
       @gr.reset_grammar if needs_reset
      
       p "set state"
       @key_input_state = InputState.new if needs_reset
       @civ.key_hints = @key_input_state.state
      end 
    end
    
    if (@key == :space)
      res, following = Dictionary.complete_me(@dr.req_str, @gr.next_filter, @gr.context)
      if (res == nil)
        @rq.enq SystemsMessage.new("#{@dr.req_str} is not in #{@gr.context} dictionary", SystemMyself, :warn)
        reset
        raise
      else
        #SoundPlay.play_sound(0)
        @dr.req_str = res[:word]
        p "req_str = #{@dr.req_str}"
        @dr.req_grammar = res[:grammar]
        @gr.set_grammar(res[:grammar])
        @gr.context ||= res[:sys]

        until following.nil?
          @dr.add_req @civ
          @dr.replace_req @civ
          @dr.req_str = following[:word]
          @dr.req_grammar = following[:grammar]
          @gr.set_grammar(following[:grammar])
          follow_word = following[:following]
          following = nil
          following = Dictionary.matching_word(follow_word.to_s) unless follow_word.nil?
        end
      end
      @dr.add_req @civ
    end
    
    @dr.replace_req @civ

    if (@key == :return)                 
      begin
        if @dr.fullCommand.size > 1
          p "Full command = #{@dr.fullCommand}"

          resp_hash = ShipSystem.command_parser(@dr.fullCommand, @rq)
                   
          if (resp_hash[:success])
            media_lp = @ship.locationPoint
            media_lp = resp_hash[:sgo].centrePoint unless resp_hash[:sgo].nil?
            MediaManager.show_media(@im_win,resp_hash[:media],media_lp) unless resp_hash[:media].nil?
          else 
            #SoundPlay.play_sound(5)
          end
          
          talk_screen resp_hash[:talk],resp_hash[:name]  unless resp_hash[:talk].nil?
        else
          SystemNavigation.status
        end

        #if (!@ship.headingPoint.nil?)
        #  @heading_para.replace @ship.headingPoint, :stroke => white, :left => 50
        #  @heading_icon.show
        #else
        #  @heading_icon.hide
        #end   
        #@action_para.replace @ship.describeLocation, :stroke => white, :left => 50
        #either the current body is a planet, or the owning body.
        #local_body = @ship.locationPoint.body
        #local_planet = (local_body.kind_of? Planet)? local_body.name : local_body.owning_body.name
        
        #read mail
        mail = SimpleBody.get_mail.shift
        @ship.push_mail(mail.txt, mail.from) unless mail.nil?
        
        if @ship.has_new_mail?
          new_mail = @ship.read_mail(:position => :new, :consume => false)
          @rq.enq SystemsMessage.new("You have mail from '#{new_mail.from}'", SystemCommunication, :flag) if @rq.peek.flavour != :report
        end
        
        #read comms
        unless SimpleBody.get_comms.empty?
          @rq.enq SystemsMessage.new(SimpleBody.get_comms.shift, SystemCommunication, :flag)
        end 
         
      rescue => ex
         p "SystemMessage: #{ex}"
         @rq.enq SystemsMessage.new("#{ex}", SystemMyself, :warn)            
      end

      @civ.last_command[1] = @dr.fullCommand  if @dr.fullCommand.size > 1
      reset
    end
    
    if (@key == :f1)                 
      begin
          command = read_script
          @dr.script_command = command
          p "script command = #{command}"

          resp_hash = ShipSystem.command_parser(command, @rq)
                   
          if (resp_hash[:success])
            media_lp = @ship.locationPoint
            media_lp = resp_hash[:sgo].centrePoint unless resp_hash[:sgo].nil?
            MediaManager.show_media(@im_win,resp_hash[:media],media_lp) unless resp_hash[:media].nil?
          else 
            #SoundPlay.play_sound(5)
          end
          
          talk_screen resp_hash[:talk],resp_hash[:name] unless resp_hash[:talk].nil?
       
        #if (!@ship.headingPoint.nil?)
        #  @heading_para.replace @ship.headingPoint, :stroke => white, :left => 50
        #  @heading_icon.show
        #else
        #  @heading_icon.hide
        #end   
        #@action_para.replace @ship.describeLocation, :stroke => white, :left => 50
        #either the current body is a planet, or the owning body.
        #local_body = @ship.locationPoint.body
        #local_planet = (local_body.kind_of? Planet)? local_body.name : local_body.owning_body.name
        
        #read mail
        mail = SimpleBody.get_mail.shift
        @ship.push_mail(mail.txt, mail.from) unless mail.nil?
        
        if @ship.has_new_mail?
          new_mail = @ship.read_mail(:position => :new, :consume => false)
          @rq.enq SystemsMessage.new("You have mail from '#{new_mail.from}'", SystemCommunication, :flag) if @rq.peek.flavour != :report
        end            
         
      rescue => ex
         @rq.enq SystemsMessage.new("#{ex}", SystemMyself, :warn)            
      end

      @civ.last_command[1] = @dr.fullCommand  if @dr.fullCommand.size > 1
      @dr.script_command = nil
      reset
    end
  end  
end    