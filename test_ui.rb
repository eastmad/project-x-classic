require "control_systems/ship_system"
require "control_systems/dictionary"
require "control_systems/operation"
require "control_systems/system_power"
require "control_systems/system_weaponry"
require "control_systems/system_navigation"
require "control_systems/system_communication"
require "control_systems/system_security"
require "interface/action_line"
require "interface/system_message"
require "interface/response_queue"

Shoes.app(:width => 500, :height => 400, :title => "ProjectX") {

   @rq = ResponseQueue.new   
   @ap = [ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new, ActionLine.new]
   @ma = ActionLine.new
   
   stack(:width => 450) {
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
               @rq.enq SystemsMessage.new("Fire controls locked out when docked.", SystemWeaponry, :warn)
               @rq.enq SystemsMessage.new("Description of firing\nand shit", SystemWeaponry, :report) 
            else
              @feedback.text = "Parser: I don't know #{@ed.text}" 
            end          
            
         end
      }
      @feedback = para
   }
   stack(:width =>550, :height => 150) {            
      (0..4).each{|n| @ap[n].line_type = caption strong(""),""}
   }
   stack(:width =>550, :height => 150) {            
      @ma.line_type = caption strong("poo"),""
   }
   
   every (1) {
      unless @rq.peek.nil?
         message = @rq.deq

         unless (message.flavour == :mail || message.flavour == :report)
            (4.downto 1).each do |n|
                @ap[n].line_type.show
                @ap[n].set_line @ap[n - 1]
             end
            @ap[0].set_line message
         else
            @ma.set_line message
         end   
      end
   }
   
}

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




  
