require "keystroke_reader"
require "display_response"
require "image_window"
require "media_manager"
require "sound_play"
require "simple_object_world/simple_body"
require "simple_object_world/simple_game_object"
require "simple_object_world/location_point"
require "simple_object_world/location_link"
require "control_systems/dictionary"
require "control_systems/grammar_tree"
require "control_systems/ship_registry"
require "control_systems/ship_system"
require "control_systems/system_power"
require "control_systems/system_weapon"
require "control_systems/system_navigation"
require "control_systems/operation"
require "control_systems/system_communication"
require "control_systems/system_security"

require "interface/action_line"
require "interface/system_message"
require "interface/response_queue"

Shoes.app (:width => 550, :height => 250, :title => "ProjectX") {
   background black
   stroke white
   
   sol = Star.new("Sol")
   Dictionary.add_discovered_proper_noun(sol.name, sol)
   earth = Planet.new("Earth", sol.outerPoint)
   Dictionary.add_discovered_proper_noun(earth.name, earth)
   mars = Planet.new("Mars", sol.outerPoint)
   Dictionary.add_discovered_proper_noun(mars.name, mars)
   station = Moon.new("Sputnik", earth.outerPoint)
   Dictionary.add_discovered_proper_noun(station.name, station)

   @ship = ShipRegistry.register_ship("ProjectX",station.outerPoint)
   Dictionary.add_discovered_proper_noun(@ship.name, nil) #should be an sgo
   ShipSystem.christen(@ship)
   Operation.register_op :launch, :power, 1
   Operation.register_op :undock, :power, 1
   Operation.register_op :fire, :weapon, 1
   Operation.register_op :compute, :navigation, 1
   Operation.register_op :dock, :power, 1
   Operation.register_op :orbit, :power, 1
   Operation.register_op :plot, :navigation, 1
   Operation.register_op :engage, :power, 1
   
   @rq = ResponseQueue.new
   @ap = [ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new]
   stack(:width =>210) {
                           
      @im_win = ImageWindow.new(:station)     
           
      @imstack = stack {
         image @im_win.first_image()      
      } 
      animate (2) do | frame |                     
        @imstack.clear { image @im_win.animate_image(frame)}                     
      end
      
      @iconstack = stack {
         flow {
            image "gifs/star_icon.gif", :width => 15, :height => 16
            inscription "Sol", :stroke => white
         }
      
         @heading_icon = flow {
            image "gifs/head_icon.gif"
            @heading_inscription = inscription "orbit", :stroke => white
         }
         @heading_icon.hide
         
         @action_icon = flow {
            image "gifs/loc_icon.gif"
            @action_inscription = inscription @ship.locationPoint, :stroke => white
         }
      }
      
      @iconstack.move(0,parent.height - 90)
   }

   stack(:width => 300)  {      
      @dr = DisplayResponse.new 
      @gr = GrammarTree.new

      @state = :empty
      @arr = Array.new(7)
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
      
      @ap[0].line_type = para ""
      @ap[1].line_type = para ""
      @ap[2].line_type = para ""
      @ap[3].line_type = para ""
      @ap[4].line_type = para ""
      
      every (1) {
        unless @rq.peek.nil?     
          line = @rq.deq
          
          @ap[4].copy_line @ap[3]
          @ap[3].copy_line @ap[2]
          @ap[2].copy_line @ap[1]
          @ap[1].copy_line @ap[0]
          @ap[0].line_type.text = line.make_string
          @ap[0].response_type = line.flavour
          @ap[0].set_stroke line.flavour 
        end
      }
      
      sounds = Array.new
      num = 1
        
      while File.exists?(SoundPlay.load_sound(num)) do    
         s = SoundPlay.load_sound(num)
         sound = video s          
         info "sound=#{sound.inspect}"
         SoundPlay.register_sound(sound)     
         num += 1
      end  
      SoundPlay.hide_sounds()      
      
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
            res = Dictionary.complete_me(@dr.req_str, @gr.next_filter)
            if (res == nil)
              @rq.enq SystemsMessage.new("#{@dr.req_str} is not in dictionary", SystemCommunication, :warn)
            else
               SoundPlay.play_sound(0)
               @dr.req_str = res[:word]
               @dr.req_grammar = res[:grammar]
               @gr.set_grammar(res[:grammar])  
            end                           
            @dr.add_req               
            @dr.replace_req @arr            
         end
          
         if (@state == :done)                 
            begin
               resp_hash = ShipSystem.command_parser(@dr.fullCommand, @rq)
               
               if (resp_hash[:success])
                  MediaManager.show_media(@im_win,resp_hash[:media]) 
               else 
                   SoundPlay.play_sound(5)
               end 
               
               if (!@ship.headingPoint.nil?)
                  @heading_inscription.replace @ship.headingPoint.body, :stroke => white
                  @heading_icon.show
               else
                  @heading_icon.hide
               #@heading_inscription.hide
               end   
               @action_inscription.replace @ship.status, :stroke => white            
            rescue => ex
               @rq.enq SystemsMessage.new("#{ex}", SystemCommunication, :warn)            
            end
            
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

