class ShipSystem
 
 @@rq = nil
 
 def self.set_rq rq
   @@rq = rq
 end
 
 def self.command_parser command_str, rq
 
   command_verb = command_str.split.first
   #info "command_verb = #{command_verb}"
   req_op = Operation.find_op(command_verb.to_sym)
   raise "No operation corresponds to command '#{command_verb}'" if req_op.nil? 
   
   command_sys = find_system(req_op[:ship_system])
   command_sys.set_rq rq
   resp_hash = command_sys.evaluate(command_str)

   #resp_window.replace "#{command_sys.cursor_str}: #{resp_hash[:str]}"   
   #rq.enq SystemsMessage.new(resp_hash[:str], command_sys, :response)
         
   resp_hash
 end
 
 
 def self.evaluate(script)       
    debug "Call evaluate for command '#{script}'"
             
    words = script.split
    processed_script = ""
    words.each do |word| 
      word = word[0, 1].downcase + word[1..-1] 
      processed_script += "_#{word} "
    end 
    
    #info "processed '#{processed_script}'"
    
    self.new.instance_eval(processed_script)     
    
 end   

 
 def self.christen(data)
   @@ship = data
 end
 
 def self.find_system(sys_symbol)
  
   sys = nil
  
   klassname = "System" + sys_symbol.to_s.capitalize
        
   sys = eval(klassname)
   
   return sys
   
 end
 
 def self.make_proper_noun word
   word = word[0, 1].capitalize + word[1..-1]
 end
 
 def self.is_proper_noun?(word)   
   word = ShipSystem.make_proper_noun(word)
   
   dic_entry = Dictionary.matching_word(word)
   if !dic_entry.nil? and (dic_entry[:grammar] == :proper_noun) 
      return true
   end
   
   false
 end
 
 def self.is_item?(word)   
   dic_entry = Dictionary.matching_word(word)
   if !dic_entry.nil? and (dic_entry[:grammar] == :item) 
      return true
   end
   
   false
 end
 
 def self.find_sgo_from_name(name)
   dic_entry = Dictionary.matching_word(name)
   
   ret = nil
   
   if !dic_entry.nil?      
     ret = dic_entry[:sgo]
     debug "Found entry #{ret} for proper name #{name}"
   else
     warn "Cannot find entry for proper name #{name}"
   end
   
   ret
   
 end
 
 def self.cursor_str
   "Sys"
 end
 
 def self.status
    @@rq.enq SystemsMessage.new("System cannot report it's status yet", SystemMyself, :info)
 end
 
 def get_system_from_symbol sym
   sys_string = "System#{sym.to_s.capitalize}"
   info "Sys string #{sys_string}"
   sys = Kernel.const_get(sys_string)
   sys
 end
 
 def method_missing (methId, *args)      
   word = methId.id2name
   #info "(methId, *args) Call method missing:#{word} and #{args.length} "

   ret = word.slice!(0)
   info "is #{word} proper noun?"
   if ShipSystem.is_proper_noun?(word)
     ret = ShipSystem.make_proper_noun(word)
     if (@obj.nil?)
       @obj = ret
     end
   elsif ShipSystem.is_item?(word)
     if (@obj.nil?)
       @obj = ret
     end
   end

   ret
 end
end