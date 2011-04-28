class GameStart

 def self.data
  sol = Star.new("Sol", "Your home planet's sun")
  Dictionary.add_discovered_proper_noun(sol.name, sol)
  earth = sol.planetFactory("Earth","Your home planet")
  Dictionary.add_discovered_proper_noun(earth.name, earth)
  mars = sol.planetFactory("Mars", "Known as the red planet")
  Dictionary.add_discovered_proper_noun(mars.name, mars)
  venus = sol.planetFactory("Venus", "Known for mining")
  Dictionary.add_discovered_proper_noun(venus.name, venus)
  listeningPost = mars.structureFactory("Owl23", "Unknown structure", 2)
  Dictionary.add_discovered_proper_noun(listeningPost.name, listeningPost)

  sputnik = earth.stationFactory("Sputnik", "One of the oldest space stations")
  Dictionary.add_discovered_proper_noun(sputnik.name, sputnik)
  mall = earth.stationFactory("OrbitalMall", "A Modern trading space stations")
  Dictionary.add_discovered_proper_noun(mall.name, mall)
  servicestation = venus.stationFactory("ServiceShop", "A service station")
  Dictionary.add_discovered_proper_noun(servicestation.name, servicestation)
  
  houston =  earth.cityFactory("Houston", "Main space port for Earth, based in old continental America")
  Dictionary.add_discovered_proper_noun(houston.name, houston)
  marsport = mars.cityFactory("Dundarach", "Only space port for Mars, sometimes refered to as Marsport")
  Dictionary.add_discovered_proper_noun(marsport.name, marsport)
  nicosia = mars.cityFactory("Nicosia", "Now deserted city, location of the first Mars independence revolt.")
  Dictionary.add_discovered_proper_noun(nicosia.name, nicosia)
  
  trader = mall.traderFactory("Buffet", :Industries, "Trading in ice cream components")
  trader2 = mall.traderFactory("Amstrad", :Intergalactic, "Trading in faulty computing equipment")
  #garage = servicestation.garageFactory("Minestar", :Garages, "Service garage")
  garage = sputnik.garageFactory("Minestar", :Garages, "Service garage")
  item = Item.new("blackberries", "A juicy forest fruit", :commodity)
  Dictionary.add_discovered_item(item.name, item)  
  trader.add_sink_trade(item)
  item = Item.new("choclate chips", "Confectionary additions", :commodity)
  Dictionary.add_discovered_item(item.name, item)  
  trader.add_sink_trade(item)
  item = Item.new("wafer cones", "Confectionary containers", :commodity)
  Dictionary.add_discovered_item(item.name, item)  
  trader2.add_source_trade(item)
  trader.add_sink_trade(item)
  garage.add_service_module(Torpedo)
  
  eye = Item.new("horus eye", "Alien artifact, possibly of Martian origin", :unique, [:controlled, :alien])
  Dictionary.add_discovered_item(eye.name, eye)

  trader2.add_source_trade(eye,1)
      
  Dictionary.add_double_discovered_proper_noun(trader.name, trader.index_name, trader)
  Dictionary.add_double_discovered_proper_noun(trader2.name, trader2.index_name, trader2)
  Dictionary.add_double_discovered_proper_noun(garage.name, garage.index_name, garage)

  freemars = Organisation.new("Free Mars", "Independence for Mars!", :secret)
  freemars.add_message(:visit_mars,"New Nicosia is still desolate from when Earth forces levelled it after the rebellion.\
 If you want to know more about what's happening to Mars, talk to our contact on Earth.")
  pers = houston.contactFactory(:m, "Pers", "Nordstrum", "Alien artifact trader", freemars, 1)
  pers.add_details(:interest => :alien, :talk => :war)

  listeningPost.add_updated_desc(2, "Earth military control listening post", freemars)
  
  nicosia.add_visit_trigger(freemars, 1, :visit_mars)

  ship = ShipRegistry.register_ship("ProjectX",sputnik.surfacePoint)
  Dictionary.add_discovered_proper_noun(ship.name, nil) #should be an sgo
  ShipSystem.christen(ship)
  
  ship.push_mail(SystemGhost.welcome, "ghost")
  
  ship
 end
 
 def self.welcome
  poop =  window(:title => "Welcome to Project-X", :width => 500, :height => 300)  do
    background black
    stack do
      
      flow {
        caption strong("You are in control of the small vessel, Project-x.\nWhatever you are looking for, you can't remember what it is."), :stroke => white, :align => "center"
      }

      flow {
        para "\n\n- Type commands to control Project-x\n"
        para "- Try 'summarize', 'status' or 'help' to find out more commands\n", :stroke => azure
        para "- Type space or tab to complete any command\n", :stroke => azure
        para "- Your vessel is in an old space station\n", :stroke => azure
        para "- The first command to try is probably 'launch'\n", :stroke => aquamarine

      }
      keypress { | k| 
          poop.close
      }
    end
  end
 end 

end