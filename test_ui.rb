Shoes.app (:width => 500, :height => 300, :title => "ProjectX") {

   @feedback = strong("?")
   @rq = ResponseQueue.new   
   @ap = ActionPanel.new([strong(), strong(), strong(), strong(), strong()])
   
   stack (:width => 450) {
      background lightblue
      flow {
         @ed = edit_line ">"
         button "done" do
            @ap.clear_lines
            
       info "edit-line = #{@ed.text}"
       if (@ed.text.include? "launch")
               @rq.enq "Launch command confirmed."
      every (2) { 
                  @rq.enq AddPhasedActions.next_action if AddPhasedActions.any?
      }
       else
      @rq.enq "#{@ed.text}?"
       end  
            
            
         end
      }
      para @feedback
   }
   stack(:width =>550, :height => 200) {            
      para @ap.lines[0]
      inscription @ap.lines[1]
      inscription @ap.lines[2]
      inscription @ap.lines[3]
      inscription @ap.lines[4]
   }
   
   every (1) {
      unless @rq.peek.nil?
      
         @ap.lines[4].text = @ap.lines[3].text
         @ap.lines[3].text = @ap.lines[2].text
         @ap.lines[2].text = @ap.lines[1].text
         @ap.lines[1].text = @ap.lines[0].text
         @ap.lines[0].text = ""
         @ap.lines[0].text = @rq.deq unless @rq.peek.nil?
      end
   }      
}

class ActionPanel

   attr_reader :lines
   
   def initialize panelElements
      @lines = panelElements 
   end
   
   def clear_lines
      @lines.each { |line| 
         info "clear line #{line.text}"
         #line.text = ""
      }
   end

end


class AddPhasedActions

     @@a = [        
        "Main thrusters ignited.",
   "Course set for Mars.",
   "Leaving satellite gravitational influence.",
   "Currenly awaiting launch clearance."
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
