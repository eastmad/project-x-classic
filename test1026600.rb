require "local_config"
require "keystroke_reader"
require "display_response"
require "image_window"
require "media_manager"
require "sound_play"
require "simple_object_world/simple_body"
require "simple_object_world/city"
require "simple_object_world/simple_game_object"
require "simple_object_world/trade"
require "simple_object_world/trader"
require "simple_object_world/location_point"
require "simple_object_world/location_link"
require "simple_object_world/contact"
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
require "control_systems/system_weapon"
require "control_systems/system_navigation"
require "control_systems/system_communication"
require "control_systems/system_security"
require "control_systems/system_myself"
require "control_systems/system_library"
require "long_text"
require "game_start"

Shoes.app(:width => 1026, :height => 600, :title => "ProjectX") {
  
  background rgb(20, 42, 42)
  stroke white

  @ship = GameStart.data
  
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
  Operation.register_op :summarize, :myself, 1
  Operation.register_op :help, :myself, 1
  Operation.register_op :status, :myself, 1
  Operation.register_op :read, :communication, 1
  Operation.register_op :accept, :trade, 1
  Operation.register_op :fulfill, :trade, 1
  Operation.register_op :browse, :trade, 1
  Operation.register_op :contact, :communication, 1
  Operation.register_op :view, :communication, 1
  Operation.register_op :meet, :communication, 1 
  Operation.register_op :suggest, :myself, 1
  Operation.register_op :manifest, :trade, 1
  Operation.register_op :bay, :trade, 1
   
  @rq = ResponseQueue.new
  @ap = [ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new]
  
  @backstack = stack(:hidden => true){
    flow(:width => 800) {
      image "gifs/contact.jpg"
      caption " Newton Todd", :stroke => white
      inscription "        F1 - exit   F2 - finish", :stroke => darkgray
    }  
    
    @t = tagline "", :stroke => white
       
    keypress {|k|
      if k == :f1 
        info "end it"
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
      flow {
        image "gifs/star_icon.gif", :width => 30, :height => 32
        inscription "Sol", :stroke => white
      }

      @planet_icon = flow {
        image "gifs/planet_icon.gif"
        @planet_inscription = inscription "Earth", :stroke => white
      }

      @heading_icon = flow {
        image "gifs/head_icon.gif"
        @heading_inscription = inscription "orbit", :stroke => white
      }
      @heading_icon.hide

      @action_icon = flow {
        image "gifs/loc_icon.gif"
        @action_inscription = inscription @ship.describeLocation, :stroke => white
      }
    }

    @iconstack.move(0,parent.height - 260)
  }

  @mainstack2 = stack(:width => 500)  {  
    @dr = DisplayResponse.new 
    @gr = GrammarTree.new

    @state = :empty
    @arr = Array.new(7)

    stack {
      border rgb(25,25,50) , :strokewidth => 1
      background rgb(20, 42, 42)
      flow {
        para "> ", :stroke => white
        @arr[0] = para "_", :stroke => white
        (1..6).each{|n| @arr[n] = para " ", :stroke => white}
      }
      @last_command = inscription "Waiting for command", :stroke => gray
    }  

    stack(:width => 500, :height => 462){
      background rgb(20,20,40)
      border rgb(25,25,50) , :strokewidth => 1
      (0..4).each{|n| @ap[n].line_type = para strong(""),""}
    }
    
    every (1) {
      unless @rq.peek.nil?     
        message = @rq.deq

        if (message.flavour == :mail || message.flavour == :report)
          (4.downto 1).each {|n| @ap[n].line_type.hide}
        else
          @ap[0].set_line @old_top_message if (@ap[0].flavour == :mail || @ap[0].flavour == :report)
          (4.downto 1).each do |n|
             @ap[n].line_type.show
             @ap[n].set_line @ap[n - 1]
          end
          @old_top_message = message.dup
        end
        @ap[0].set_line message        
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

    keypress { |k|
      key_resp = KeystrokeReader.key_in(k,@dr.req_str)
      @dr.req_str = key_resp[:str]
      @state = key_resp[:state]                   
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
      end

      if (@state == :done)                 
        begin
          if @dr.fullCommand.size > 1            
            resp_hash = ShipSystem.command_parser(@dr.fullCommand, @rq)
 
            if (resp_hash[:success])
              MediaManager.show_media(@im_win,resp_hash[:media],@ship.locationPoint) unless resp_hash[:media].nil?
            else 
                SoundPlay.play_sound(5)
            end
          else
            SystemNavigation.status
          end

          if (!@ship.headingPoint.nil?)
            @heading_inscription.replace @ship.headingPoint, :stroke => white
            @heading_icon.show
          else
            @heading_icon.hide
          end   
          @action_inscription.replace @ship.describeLocation, :stroke => white
          #either the current body is a planet, or the owning body.
          local_body = @ship.locationPoint.body
          local_planet = (local_body.kind_of? Planet)? local_body.name : local_body.owning_body.name 
          @planet_inscription.replace local_planet, :stroke => white
          
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
  
  def talk_screen txt_key
    @mainstack1.hide
    @mainstack2.hide
    @backstack.show  
          
    str = LongText.txt txt_key
    info "start timer"          

    @end_text_talk = false
    @count_rate = 1
    count = 0
    txt_timer = animate(10){ |frame|
      @t.replace(str[0,count]) if count < str.length
      count += @count_rate
      if @end_text_talk
        info "stop timer"
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
  end   
  
}

