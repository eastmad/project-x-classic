  


class Operation
   
   @@opers = nil
   private_class_method :new
   
   def self.register_op(command_verb, sys, op_id) 
      @@opers = Array.new unless @@opers
      
      ophash = {:command_verb => command_verb, :ship_system => sys, :op_id => op_id}
      @@opers << ophash
   end
   
   def self.find_op(command_verb, noun = nil)
      @@opers = Array.new unless @@opers
      
      @@opers.each do | oper |
         if oper[:command_verb] == command_verb
            return oper
         end
      end
      
      return nil
   end
   
   def self.find_op_from_command(command_string)
      command_verb = command_string.split.first
      Operation.find_op(command_verb.to_sym)
   end
   
   def self.inspect
      @@opers
   end
   
end



