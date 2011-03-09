class GameStart

 def self.data
  sol = Star.new("Sol", "Your home planet's sun")
  Dictionary.add_discovered_proper_noun(sol.name, sol)
  earth = sol.planetFactory("Earth","Your home planet")
  Dictionary.add_discovered_proper_noun(earth.name, earth)
  mars = sol.planetFactory("Mars", "Known as the red planet")
  Dictionary.add_discovered_proper_noun(mars.name, mars)
  station = earth.stationFactory("Sputnik", "One of the oldest space stations")
  Dictionary.add_discovered_proper_noun(station.name, station)
  houston =  earth.cityFactory("Houston", "Main space port for Earth, based in old continentel America")
  Dictionary.add_discovered_proper_noun(houston.name, houston)
  marsport = mars.cityFactory("Dundarach", "Only space port for Mars, sometimes refered to as Marsport")
  Dictionary.add_discovered_proper_noun(marsport.name, marsport)
  listeningPost = mars.structureFactory("Hawk23", "Earth military control listening post")
  Dictionary.add_discovered_proper_noun(listeningPost.name, listeningPost)

  trader = station.traderFactory("Buffet", :Industries, "Trading in ice cream components")
  trader2 = station.traderFactory("Amstrad", :Intergalactic, "Trading in faulty computing equipment") 
  item = Item.new("blackberries", "A juicy forest fruit", :commodity)
  Dictionary.add_discovered_subject(item.name, item)  
  trader.add_sink_trade(item)
  item = Item.new("choclate chips", "Confectionary additions", :commodity)
  Dictionary.add_discovered_subject(item.name, item)  
  trader.add_sink_trade(item)
  item = Item.new("wafer cones", "Confectionary containers", :commodity)
  Dictionary.add_discovered_subject(item.name, item)  
  trader2.add_source_trade(item)
  trader.add_sink_trade(item)
  
  eye = Item.new("horus eye", "Alien artifact of unknown origin", :unique, [:controlled, :alien])
  Dictionary.add_discovered_subject(eye.name, eye)

  trader2.add_source_trade(eye,1)
      
  Dictionary.add_double_discovered_proper_noun(trader.name, trader.index_name, trader)
  Dictionary.add_double_discovered_proper_noun(trader2.name, trader2.index_name, trader2)

  ship = ShipRegistry.register_ship("ProjectX",station.surfacePoint)
  Dictionary.add_discovered_proper_noun(ship.name, nil) #should be an sgo
  ShipSystem.christen(ship)
  
  ship.push_mail(SystemGhost.welcome, "ghost")
  
  ship
 end

end