class ShipStateMachine

   @@current_state = :rest
   
   class << self    
      [{:name => :launch, :start_state => :rest, :end_state => :sync, :result => "launched!", :fail => "can't launch!"}, 
       {:name => :land, :start_state => :sync,  :end_state => :rest, :result => "landed!", :fail => "can't land!"}
      ].each do |transition|
         define_method transition[:name] do
            raise transition[:fail] if @@current_state != transition[:start_state]
            @@current_state = transition[:end_state]
            transition[:result]
         end
      end
   end   

end