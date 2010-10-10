require "control_systems/ship_system"
require "control_systems/system_power"
require "control_systems/system_weapon"
require "control_systems/system_navigation"
require "control_systems/system_communication"
require "control_systems/system_security"

Shoes.app (:width => 500, :height => 300, :title => "ProjectX") {

   @rq = ResponseQueue.new   
   @ap = [ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new]
   
   stack (:width => 450) {
      background lightblue
      flow {
         @ed = edit_line ">"
         button "done" do
            @feedback.text = ""
            if (@ed.text.include? "launch")
              @rq.enq SystemsMessage.new("Launch command confirmed.", SystemPower, :response)
              every (2) { 
                @rq.enq AddPhasedActions.next_action if AddPhasedActions.any?
              }
            elsif (@ed.text.include? "undock")
               @rq.enq SystemsMessage.new("Releasing docking clamps.", SystemSecurity, :response)
            elsif (@ed.text.include? "fire")
               @rq.enq SystemsMessage.new("Fire controls locked out when docked.", SystemWeapon, :warn)   
            else
              @feedback.text = "Parser: I don't know #{@ed.text}" 
            end          
            
         end
      }
      @feedback = para
   }
   stack(:width =>550, :height => 200) {            
      @ap[0].line_type = inscription ""
      @ap[1].line_type = inscription ""
      @ap[2].line_type = inscription ""
      @ap[3].line_type = inscription ""
      @ap[4].line_type = inscription ""
   }
   
   every (1) {
      unless @rq.peek.nil?     
         @ap[4].copy_line @ap[3]
         @ap[3].copy_line @ap[2]
         @ap[2].copy_line @ap[1]
         @ap[1].copy_line @ap[0]
         #@ap[0].line_type.text = ""
         line = @rq.deq
         @ap[0].line_type.text = line.make_string
         @ap[0].response_type = line.flavour
         @ap[0].set_stroke line.flavour   
      end
   }
   
}

class ActionLine

   attr_accessor :line_type, :response_type
   
   def copy_line other_line
      @line_type.text = other_line.line_type.text
      set_stroke other_line.response_type
      @response_type = other_line.response_type
   end
   
   def set_stroke flav
   
      case flav   
       when :response
         @line_type.stroke = rgb(50,50,200)
       when :warn
         @line_type.stroke = rgb(200,50,50)
       else
         @line_type.stroke = rgb(0,0,0)
      end
   
   end
   
end

class SystemsMessage
   attr_reader :text, :origin, :flavour 

   def initialize txt, orig = nil, flav = :info
      @text = txt
      @origin = orig
      @flavour = flav
   end
   
   def make_string
      str = origin.cursor_str unless origin.nil?
      str << ": #{@text}"
      str
   end
end

class AddPhasedActions

     @@a = [        
        SystemsMessage.new("Main thrusters ignited.", SystemPower),
   SystemsMessage.new("Course set for Mars.", SystemNavigation),
   SystemsMessage.new("Leaving satellite gravitational influence.", SystemNavigation),
   SystemsMessage.new("Currenly awaiting launch clearance.", SystemCommunication)
      ]

   def self.next_action()
      @@a.pop
   end

   def self.any?
     return true if @@a.size > 0
     false
   end
end




class ResponseQueue
   def initialize
      @queue = []
   end

   def enq obj
      @queue << obj
   end

   def deq
      @queue.shift
   end

   def peek
      @queue.last
   end
end   
