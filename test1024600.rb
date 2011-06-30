require "local_config"
require "keystroke_reader"
require "display_response"
require "image_window"
require "media_manager"
require "sound_play"
require "simple_object_world/simple_body"
require "simple_object_world/trustee"
require "simple_object_world/trust_holder"
require "simple_object_world/city"
require "simple_object_world/simple_game_object"
require "simple_object_world/trade"
require "simple_object_world/trader"
require "simple_object_world/location_point"
require "simple_object_world/location_link"
require "simple_object_world/contact"
require "simple_object_world/modification"
require "interface/action_line"
require "interface/system_message"
require "interface/response_queue"
require "control_systems/dictionary"
require "control_systems/grammar_tree"
require "control_systems/ship_registry"
require "control_systems/ship_system"
require "control_systems/ship_data"
require "control_systems/operation"
require "control_systems/system_ghost"
require "control_systems/system_trade"
require "control_systems/system_power"
require "control_systems/system_weaponry"
require "control_systems/system_navigation"
require "control_systems/system_communication"
require "control_systems/system_security"
require "control_systems/system_myself"
require "control_systems/system_library"
require "control_systems/system_module"
require "minimap/mini_map"
require "long_text"
require "game_start"

Shoes.app(:width => 946, :height => 545, :title => "ProjectX") {
  
  background rgb(20, 42, 42)
  stroke white

  @ship = GameStart.data
  @minimap = MiniMap.new(10,30,50)
  @minimap.set_location_point(@ship.locationPoint)
  
  Operation.register_op :launch, :power, 1
  Operation.register_op :land, :power, 1
  Operation.register_op :undock, :power, 1
  Operation.register_op :approach, :power, 1
  Operation.register_op :release, :security, 1
  Operation.register_op :dock, :power, 1
  Operation.register_op :describe, :library, 1
  Operation.register_op :orbit, :navigation, 1
  Operation.register_op :plot, :navigation, 1
  Operation.register_op :engage, :power, 1
  Operation.register_op :status, :myself, 1
  Operation.register_op :help, :myself, 1
  Operation.register_op :read, :communication, 1
  Operation.register_op :accept, :trade, 1
  Operation.register_op :give, :trade, 1
  Operation.register_op :browse, :trade, 1
  Operation.register_op :contact, :communication, 1
  Operation.register_op :view, :communication, 1
  Operation.register_op :meet, :communication, 1 
  Operation.register_op :suggest, :myself, 1
  Operation.register_op :manifest, :trade, 1
  Operation.register_op :bay, :trade, 1
  Operation.register_op :destroy, :weaponry, 1
  Operation.register_op :load, :weaponry, 1
  Operation.register_op :install, :modification, 1
 
   
  @rq = ResponseQueue.new
  @ap = [ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new]
  @ma = ActionLine.new
  
  GameStart.welcome
  
  @backstack = stack(:hidden => true){
    flow(:width => 976) {
      image "gifs/contact.jpg"
      caption " Newton Todd", :stroke => white
      para "        F1 - exit   F2 - finish", :stroke => darkgray
    }  
    
    @t = tagline "", :stroke => white
       
    keypress {|k|
      if k == :f1 
        @end_text_talk = true
      elsif k == :f2
        @count_rate = 20
      end
    }
  }
  @mainstack1 = stack(:width =>320) {
    background black
    @im_win = ImageWindow.new(:stationdocked)     

    @imstack = stack {
      image @im_win.first_image()      
    } 
    animate (4) do | frame |                     
      @imstack.clear { image @im_win.animate_image(frame)}                     
    end

    @iconstack = stack {
      
      #flow {
      #  @action_icon = image "gifs/loc1_icon.gif", :width => 32, :height => 30, :left => @minimap.current_level[:left]
      #  @action_para = para @ship.describeLocation, :stroke => white, :left => @minimap.current_level[:left] + 30
      #}
      
      flow {
        @mm_top_level_image = image @minimap.top_level[:image], :width => @minimap.top_level[:size][:width], :height => @minimap.top_level[:size][:height], :left => @minimap.top_level[:left]
        @mm_top_level_para = para @minimap.top_level[:name], :stroke => white, :left => @minimap.top_level[:left] + @minimap.top_level[:size][:width]
      }

      flow {
        @mm_current_level_image = image @minimap.current_level[:image], :width => @minimap.current_level[:size][:width], :height => @minimap.current_level[:size][:height], :left => @minimap.current_level[:left]
        @mm_current_level_para = para @minimap.current_level[:name], :stroke => white, :left => @minimap.current_level[:left] + @minimap.current_level[:size][:width]
        @action_icon = image "gifs/loc_icon.gif", :width => 36, :height => 24
        @action_icon1 = image "gifs/loc1_icon.gif", :width => 36, :height => 24
        @action_icon1.hide
      }
      
      flow {
        @mm_opt_level_image = image "gifs/blank_icon.gif", :width => 30, :height => 32, :left => 50
        @mm_opt_level_para = para "", :stroke => white, :left => 80
      }
      
      flow {
        @mm_opt_level_image2 = image "gifs/blank_icon.gif", :width => 30, :height => 32, :left => 50
        @mm_opt_level_para2 = para "", :stroke => white, :left => 80
      }

      #@heading_icon = flow {
      #  image "gifs/head_icon.gif", :width => 30, :height => 32, :left => 15
      #  @heading_para = para "orbit", :stroke => white, :left => 50
      #}
      #@heading_icon.hide
    }

    @iconstack.move(0,parent.height - 200)
  }

  @mainstack2 = stack(:width => 615)  {  
    @dr = DisplayResponse.new 
    @gr = GrammarTree.new

    @state = :empty
    @arr = Array.new(7)

    stack {
      border rgb(25,25,50) , :strokewidth => 1
      background rgb(20, 42, 42)
      flow {
        caption "> ", :stroke => white
        @arr[0] = caption "_", :stroke => white
        (1..6).each{|n| @arr[n] = caption " ", :stroke => white}

        @arrow_key = image "gifs/arrow-key.jpg", :width => 16, :height => 16, :right => 150
        @space_key = image "gifs/space-key.jpg", :width => 50, :height => 16, :right => 90
        @alpha_key = image "gifs/a-key.jpg", :width => 16, :height => 16, :right => 60
        @return_key = image "gifs/return-key.jpg", :width => 22, :height => 16, :right => 30
        
        @space_key.hide
        @arrow_key.hide
        @return_key.hide
      }
      @last_command = para "Waiting for command", :stroke => gray
    }  

    stack(:width => 615, :height => 250){
      background rgb(20,20,40)
      border rgb(25,25,50) , :strokewidth => 1
      (0..7).each{|n| @ap[n].line_type = caption strong(""),""}
    }
    
    stack(:width => 615, :height => 212){
      background rgb(30,30,50)
      border rgb(25,25,50) , :strokewidth => 1
      @ma.line_type = caption strong(""),""
    }
    
    
    every (1) {
      unless @rq.peek.nil?     
        message = @rq.deq

        unless (message.flavour == :mail || message.flavour == :report)
          (7.downto 1).each do |n|
             @ap[n].line_type.show
             @ap[n].set_line @ap[n - 1]
          end
          @ap[0].set_line message
        else
          @ma.set_line message
        end 
      end
    }

    sounds = Array.new
    num = 1

    if SoundPlay.sound?
      while File.exists?(SoundPlay.load_sound(num)) do    
        s = SoundPlay.load_sound(num)
        sound = video s          
        info "sound=#{sound.inspect}"
        SoundPlay.register_sound(sound)     
        num += 1
      end  
      SoundPlay.hide_sounds()      
    end

    #@rq.enq SystemGhost.welcome   
    @rq.enq SystemsMessage.new("Controller identity confirmed.", SystemSecurity, :info)
    @rq.enq SystemsMessage.new("Welcome aboard the #{@ship.name}.", SystemMyself, :response)
    @rq.enq SystemsMessage.new("#{@ship.name} is #{@ship.describeLocation}", SystemNavigation, :info)
    
    #@rq.enq SystemsMessage.new("You have mail from 'ghost'", SystemCommunication, :response)

    resps = []
    pos = 0
    keypress { |k|
      key_resp = KeystrokeReader.key_in(k,@dr.req_str)
      @dr.req_str = key_resp[:str]
      
      @state = key_resp[:state]
      
      if (key_resp[:state] == :next)
        pos += 1
        pos = 0 if pos >= resps.size
        @dr.req_str = resps[pos].to_s if resps.size > pos
      elsif (key_resp[:state] == :last)
        pos -= 1
        pos = resps.size - 1 if pos < 0
        @dr.req_str = resps[pos].to_s if resps.size > 0
      elsif (key_resp[:state] == :typing)
        resps = Dictionary.all_matching_words(@dr.req_str, @gr.next_filter, @gr.context)
        @dr.req_str = resps.first.to_s if resps.size > 0
        pos = 0
        
        @alpha_key.hide
        @arrow_key.show
        @space_key.show
        @return_key.show
      end       
      
      @dr.replace_req @arr

      if (@state == :exit)
        goodbye()
      end
      
      if (@state == :talk_test)
        talk_screen :war
      end

      if (@state == :delete)
        @gr.undo_grammar
        needs_reset = @dr.remove_req @arr            
        @dr.replace_req @arr
        @gr.reset_grammar if needs_reset
        
        @alpha_key.show
	@arrow_key.hide
        @space_key.hide
        @return_key.hide
      end

      if (@state == :complete_me)
        res, following = Dictionary.complete_me(@dr.req_str, @gr.next_filter, @gr.context)
        if (res == nil)
          @rq.enq SystemsMessage.new("#{@dr.req_str} is not in #{@gr.context} dictionary", SystemMyself, :warn)
          raise
        else
          SoundPlay.play_sound(0)
          @dr.req_str = res[:word]
          @dr.req_grammar = res[:grammar]
          @gr.set_grammar(res[:grammar])
          @gr.context ||= res[:sys]

          unless following.nil?
            @dr.add_req               
            @dr.replace_req @arr
            @dr.req_str = following[:word]
            @dr.req_grammar = following[:grammar]
            @gr.set_grammar(following[:grammar])
          end
        end                           
        @dr.add_req               
        @dr.replace_req @arr  
        
        @alpha_key.show
        @arrow_key.hide
        @space_key.hide
        @return_key.hide
      end

      if (@state == :done)                 
        begin
          if @dr.fullCommand.size > 1
            info "Full command = #{@dr.fullCommand}"

            resp_hash = ShipSystem.command_parser(@dr.fullCommand, @rq)
                     
            if (resp_hash[:success])
              media_lp = @ship.locationPoint
              media_lp = resp_hash[:sgo].centrePoint unless resp_hash[:sgo].nil?
              MediaManager.show_media(@im_win,resp_hash[:media],media_lp) unless resp_hash[:media].nil?
            else 
              SoundPlay.play_sound(5)
            end
            
            talk_screen resp_hash[:talk] unless resp_hash[:talk].nil?
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
          draw_mini_map
          
          #read mail
          mail = SimpleBody.get_mail.shift
          @ship.push_mail(mail.txt, mail.from) unless mail.nil?
          
          if @ship.has_new_mail?
            new_mail = @ship.read_mail(:position => :new, :consume => false)
            @rq.enq SystemsMessage.new("You have mail from '#{new_mail.from}'", SystemCommunication, :response) if @rq.peek.flavour != :report
          end            
           
        rescue => ex
           @rq.enq SystemsMessage.new("#{ex}", SystemMyself, :warn)            
        end

        @last_command.text = @dr.fullCommand  if @dr.fullCommand.size > 1
        reset
      end
    }
  }
  
  def draw_mini_map
    @minimap.set_location_point @ship.locationPoint
    @mm_top_level_para.replace @minimap.top_level[:name], :stroke => white, :left => @minimap.top_level[:left] + @minimap.top_level[:size][:width]
    @mm_top_level_image.path = @minimap.top_level[:image]
    @mm_top_level_image.width = @minimap.top_level[:size][:width]
    @mm_top_level_image.height = @minimap.top_level[:size][:height]
    @mm_current_level_para.replace @minimap.current_level[:name], :stroke => white, :left => @minimap.top_level[:size][:width] + @minimap.current_level[:size][:width] + @minimap.current_level[:left]
    @mm_current_level_image.path =  @minimap.current_level[:image]#, :width => @minimap.current_level[:size][:width], :height => @minimap.top_level[:size][:height], :left => @minimap.top_level[:left]
    @mm_current_level_image.width = @minimap.current_level[:size][:width]
    @mm_current_level_image.height = @minimap.current_level[:size][:height]
    @mm_current_level_image.left = @minimap.current_level[:left] + @minimap.top_level[:size][:width]
    if @ship.status == :dependent
      @action_icon.show
      @action_icon1.hide
    else  
      @action_icon.hide
      @action_icon1.show
    end  
    #@action_para.left = @minimap.current_level[:left] + @minimap.top_level[:size][:width] + @minimap.current_level[:size][:width]
    
    opt_level = @minimap.option_level
    
    unless opt_level.nil?
      @mm_opt_level_para.replace opt_level[0][:name], :stroke => white, :left => @minimap.current_level[:left] + opt_level[0][:left] + @minimap.current_level[:size][:width] + opt_level[0][:size][:width]
      @mm_opt_level_image.path = opt_level[0][:image]
      @mm_opt_level_image.left = @minimap.current_level[:left] + opt_level[0][:left] + @minimap.current_level[:size][:width]
    else
      @mm_opt_level_para.replace ""
      @mm_opt_level_image.path = "gifs/blank_icon.gif"
    end
    
    unless (opt_level.nil? or opt_level.size < 2)
      @mm_opt_level_para2.replace opt_level[1][:name],  :stroke => white, :left => @minimap.current_level[:left] + opt_level[1][:left] + @minimap.current_level[:size][:width] + opt_level[1][:size][:width]
      @mm_opt_level_image2.path = opt_level[1][:image]
      @mm_opt_level_image2.left = @minimap.current_level[:left] + opt_level[1][:left] + @minimap.current_level[:size][:width]
    else
      @mm_opt_level_para2.replace ""
      @mm_opt_level_image2.path = "gifs/blank_icon.gif"
    end
    
  end
  
  def talk_screen txt_key
    @mainstack1.hide
    @mainstack2.hide
    @backstack.show  
          
    str = LongText.txt txt_key

    @end_text_talk = false
    @count_rate = 1
    count = 0
    txt_timer = animate(10){ |frame|
      @t.replace(str[0,count]) if count < str.length
      count += @count_rate
      if @end_text_talk
        @mainstack1.show
        @mainstack2.show
        @backstack.hide
        @t.replace("")
        txt_timer.stop()
      end
    }
  end
            
  def goodbye      
    exit()
  end

  def reset     
   @dr.clear @arr            
   @state = :empty
   @gr.reset_grammar()
           
   @alpha_key.show
   @arrow_key.hide
   @space_key.hide
   @return_key.hide
  end   
  
}

