class Operation
   
   @@opers = nil
   @@systems = nil
   private_class_method :new
   
   def self.register_op(command_verb, sys, op_id) 
      @@opers = Array.new unless @@opers
      
      ophash = {:command_verb => command_verb, :ship_system => sys, :op_id => op_id}
      @@opers << ophash
   end

  def self.register_sys(sys) 
      @@systems = Array.new unless @@systems
      @@systems << sys
      Dictionary.add_system_nouns(sys)
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
   
  def self.find_all_systems
      systems_found = []
      @@systems.each do | sys |
         systems_found << sys
      end

      systems_found
   end

   def self.find_sys_commands(system)
      commands_found = []
      @@opers.each do | oper |
         if oper[:ship_system] == system
            commands_found << oper[:command_verb]
         end
      end

      commands_found
   end 

   def self.inspect
      @@opers
   end
   
end



