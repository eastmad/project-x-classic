class ShipRegistry
   private_class_method :new
   @@ships = nil
   
   def self.register_ship(ship_name, location = nil)
      @@ships = Array.new unless @@ships
      
      ship = ShipData.new(ship_name, location)
      @@ships << ship
      
      return ship
   end     
      
end







