require "local_config"
require "keystroke_reader"
require "display_response"
require "image_window"
require "media_manager"
require "sound_play"
require "simple_object_world/simple_body"
require "simple_object_world/simple_game_object"
require "simple_object_world/contract"
require "simple_object_world/trader"
require "simple_object_world/location_point"
require "simple_object_world/location_link"
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
require "control_systems/system_power"
require "control_systems/system_weapon"
require "control_systems/system_navigation"
require "control_systems/system_communication"
require "control_systems/system_security"
require "control_systems/system_myself"

Shoes.app(:width => 550, :height => 300, :title => "ProjectX") {
   

   background black
   stroke white
   
   sol = Star.new("Sol", "Your home planet's sun")
   Dictionary.add_discovered_proper_noun(sol.name, sol)
   earth = Planet.new("Earth","Your home planet", sol.orbitPoint)
   Dictionary.add_discovered_proper_noun(earth.name, earth)
   mars = Planet.new("Mars", "Known as the red planet", sol.orbitPoint)
   Dictionary.add_discovered_proper_noun(mars.name, mars)
   station = Moon.new("Sputnik", "One of the oldest space stations", earth.orbitPoint)
   Dictionary.add_discovered_proper_noun(station.name, station)
   houston = City.new("Houston", "Main space port for Earth, based in old continentel America", earth.atmospherePoint)
   Dictionary.add_discovered_proper_noun(houston.name, houston)
   marsport = City.new("Dundarach", "Only space port for Mars, sometimes refered to as Marsport", mars.atmospherePoint)
   Dictionary.add_discovered_proper_noun(marsport.name, marsport)
   
   trader = Trader.new("Buffet Industries", "BuffetInd", "Trading in ice cream components", station.centrePoint) 
   item = Item.new("blackberries")
   contract = Contract.new(:supply, item, trader)
   Dictionary.add_discovered_proper_noun(trader.index_name, trader)
   

   @ship = ShipRegistry.register_ship("ProjectX",station.surfacePoint)
   Dictionary.add_discovered_proper_noun(@ship.name, nil) #should be an sgo
   ShipSystem.christen(@ship)
   Operation.register_op :launch, :power, 1
   Operation.register_op :land, :power, 1
   Operation.register_op :undock, :power, 1
   Operation.register_op :approach, :power, 1
   Operation.register_op :release, :security, 1
   Operation.register_op :compute, :navigation, 1
   Operation.register_op :dock, :power, 1
   Operation.register_op :describe, :navigation, 1
   Operation.register_op :orbit, :navigation, 1
   Operation.register_op :plot, :navigation, 1
   Operation.register_op :engage, :power, 1
   Operation.register_op :summarize, :myself, 1
   Operation.register_op :help, :myself, 1
   Operation.register_op :status, :myself, 1

   
   @rq = ResponseQueue.new
   @ap = [ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new]
   stack(:width =>210) {
                           
      @im_win = ImageWindow.new(:stationdocked)     
           
      @imstack = stack {
         image @im_win.first_image()      
      } 
      animate (4) do | frame |                     
        @imstack.clear { image @im_win.animate_image(frame)}                     
      end
      
      @iconstack = stack {
         flow {
            image "gifs/star_icon.gif", :width => 15, :height => 16
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
      
      @iconstack.move(0,parent.height - 130)
   }

   stack(:width => 300)  {      
      @dr = DisplayResponse.new 
      @gr = GrammarTree.new

      @state = :empty
      @arr = Array.new(7)
 
      stack {
      border rgb(25,25,50) , :strokewidth => 1
      flow {
              para "> ", :stroke => white
              @req = para "_", :stroke => white     
              @req2 = para "", :stroke => white   
              @req3 = para "", :stroke => white      
              @req4 = para "", :stroke => white      
              @req5 = para "", :stroke => white      
              @req6 = para "", :stroke => white
              @req7 = para "", :stroke => white
              @arr[0] = @req
              @arr[1] = @req2
              @arr[2] = @req3
              @arr[3] = @req4
              @arr[4] = @req5
              @arr[5] = @req6
              @arr[6] = @req7
      }
      @last_command = inscription "Waiting for command", :stroke => gray
      }  
      
      @ap[0].line_type = para strong(""),""
      @ap[1].line_type = para strong(""),""
      @ap[2].line_type = para strong(""),""
      @ap[3].line_type = para strong(""),""
      @ap[4].line_type = para strong(""),""
      
      every (1) {
        unless @rq.peek.nil?     
          line = @rq.deq
          
          @ap[4].copy_line @ap[3]
          @ap[3].copy_line @ap[2]
          @ap[2].copy_line @ap[1]
          @ap[1].copy_line @ap[0]
          @ap[0].response_type = line.flavour
          @ap[0].set_stroke line.flavour 
          @ap[0].origin = line.origin
          @ap[0].line_type.contents[1].replace(line.make_string)
          @ap[0].line_type.contents[0].replace(line.origin.cursor_str)
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
      
      @rq.enq SystemGhost.welcome   
      @ap[1].hide
      @ap[2].hide
      @ap[3].hide
      @ap[4].hide
      #@rq.enq SystemsMessage.new("Controller identity confirmed.", SystemSecurity, :info)
      #@rq.enq SystemsMessage.new("Welcome aboard the #{@ship.name}.", SystemMyself, :response)
      #@rq.enq SystemsMessage.new("#{@ship.name} is #{@ship.describeLocation}", SystemNavigation, :info)

      keypress { |k|
         
         key_resp = KeystrokeReader.key_in(k,@dr.req_str)
         @dr.req_str = key_resp[:str]
         @state = key_resp[:state]                   
         @dr.replace_req @arr
      
         if (@state == :exit)
            goodbye()
         end 
         
         if (@state == :delete)
            @gr.undo_grammar
            needs_reset = @dr.remove_req @arr            
            @dr.replace_req @arr
            @gr.reset_grammar if needs_reset
         end
         
         if (@state == :complete_me)
            res, following = Dictionary.complete_me(@dr.req_str, @gr.next_filter)
            if (res == nil)
              @rq.enq SystemsMessage.new("#{@dr.req_str} is not in dictionary", SystemMyself, :warn)
            else
               SoundPlay.play_sound(0)
               @dr.req_str = res[:word]
               @dr.req_grammar = res[:grammar]
               @gr.set_grammar(res[:grammar])
               
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
               resp_hash = ShipSystem.command_parser(@dr.fullCommand, @rq)
               
               if (resp_hash[:success])
                  MediaManager.show_media(@im_win,resp_hash[:media],@ship.locationPoint) unless resp_hash[:media].nil?
               else 
                   SoundPlay.play_sound(5)
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
            rescue => ex
               @rq.enq SystemsMessage.new("#{ex}", SystemMyself, :warn)            
            end
            
            @last_command.text = @dr.fullCommand  
            reset
         end
      }
      
          
   }
            
   
   def goodbye      
      exit()
   end
   
   def reset     
     @dr.clear @arr            
     @state = :empty
     @gr.reset_grammar()
   end   
  
}

