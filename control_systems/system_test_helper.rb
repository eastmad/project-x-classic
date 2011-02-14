module TestHelper
   def find_and_evaluate(command_str)
      req_op = Operation.find_op_from_command(command_str)
      if !req_op
         warn "(No operation available - #{command_str})" 
         return
      end   
      my_sys = ShipSystem.find_system(req_op[:ship_system])   
      if !my_sys
         warn "(No system available - #{command_str})"
         return
      end
      resp_hash = my_sys.evaluate(command_str)
      puts "#{command_str} => #{resp_hash[:success]}, #{resp_hash[:media]}"
   end
   
   def test_command(str, rq)
     find_and_evaluate str
     while rq.peek
       puts rq.deq.text
     end
   end
   
   def info str
      #puts "info:#{str}"
   end
    
   def debug str
      #puts "debug:#{str}"
   end
end