class GameStart

 def self.data2
   loadGalaxy
   ImageWindow.register("Earth",{:orbit => "terre_noir", :atmosphere => "earth_atmosphere"})
   ImageWindow.register("Mars",{:orbit => "mars-planet-water-nasa"})
   ImageWindow.register("Venus",{:orbit => "venus"})
   #ImageWindow.register("Mercury",{:orbit => "mercury"})
   ImageWindow.register("Nicosia",{:centre => "ruinedcity22"})
   loadItems
   loadOrgs
   loadPeople
   
   wafercones = Item.find :wc
   eye = Item.find :eye
   trader = Trader.find :biz1
   trader2 = Trader.find :biz2
   trader3 = Trader.find(:ventrad)
   garage1 = Garage.find(:vengar)
   garage2 = Garage.find(:skull)
   freemars = Organisation.find :fm
   vmu = Organisation.find :vmu
   mt = Organisation.find :mt
   houston = City.find(:Houston)
   listeningPost = SmallStructure.find(:lp)
   nicosia = City.find(:Nicosia)
   venutia = City.find(:Venutia)
   dun = City.find(:Dundarach)
   merc = Planet.find(:Mercury)
   
   trader.add_sink_trade(Item.find :bb)
   trader.add_sink_trade(Item.find :cc)
   trader2.add_source_trade(wafercones)
   
   trader3.set_owning_org(vmu)
   trader3.add_sink_trade(wafercones)
   trader3.add_source_trade(Item.find(:tit),1)
      
   garage1.set_owning_org(vmu)
   garage1.add_service_module(GovTorpedo)
   garage1.add_service_module(HeatShieldModule,1)
   
   garage2.set_owning_org(freemars)
   garage2.add_service_module(HammerheadTorpedo,1)
   garage2.add_service_module(JumpPodModule,2)
   
   trader2.add_source_trade(eye,1)
   
   freemars.add_message(:visit_mars,"New Nicosia is still desolate from when Earth forces levelled it after the rebellion. \
If you want to know more about what's happening to Mars, talk to our contact on Earth.")
          
   pers = houston.contactFactory(Person.find(:Nordstrum), freemars, 1)
   pers.add_details(:interest => :alien, :talk => :war)
   pers = venutia.contactFactory(Person.find(:Singh), vmu, 1)
   pers.add_details(:talk => :mining_standards)
   dun.contactFactory(Person.find(:Gras), mt, 1)
   
   listeningPost.add_updated_desc(2, "Earth military control listening post", freemars)
   listeningPost.add_death_listener(freemars)
   listeningPost.add_blocker(:check_torp_class, GovTorpedo, "Cannot target government property with this munition - safety interlock")
     
   nicosia.add_visit_trigger(freemars, 1, :visit_mars)
   
   merc.add_blocker(:check_mod, :shield, "insufficient heat shielding - safety interlock")
   
   
   ship = ShipRegistry.register_ship("ProjectX",SpaceStation.find(:sputnik).surfacePoint)
   Dictionary.add_discovered_proper_noun(ship.name, nil) #should be an sgo
   ShipSystem.christen(ship)
     
   ship.push_mail(SystemGhost.welcome, "ghost")
   
   ship
 end
 
 def self.data
  galaxy = Galaxy.new("MilkyWay", "The limit of exploration")
  Dictionary.add_discovered_proper_noun(galaxy.name, galaxy)
  sol = galaxy.starFactory("Sol", "Your home planet's sun")
  Dictionary.add_discovered_proper_noun(sol.name, sol)
  earth = sol.planetFactory("Earth","Your home planet")
  ImageWindow.register("Earth",{:orbit => "terre_noir", :atmosphere => "earth_atmosphere"})
  Dictionary.add_discovered_proper_noun(earth.name, earth)
  mars = sol.planetFactory("Mars", "Known as the red planet")
  ImageWindow.register("Mars",{:orbit => "mars-planet-water-nasa"})
  Dictionary.add_discovered_proper_noun(mars.name, mars)
  venus = sol.planetFactory("Venus", "Known for mining")
  ImageWindow.register("Venus",{:orbit => "venus"})
  Dictionary.add_discovered_proper_noun(venus.name, venus)
  mercury = sol.planetFactory("Mercury", "Difficult to reach because of solar heat")
  ImageWindow.register("Mercury",{:orbit => "mercury"})
  
  Dictionary.add_discovered_proper_noun(mercury.name, mercury)

  listeningPost = mars.structureFactory("Owl23", "Unknown structure", 2)
  
  Dictionary.add_discovered_proper_noun(listeningPost.name, listeningPost)

  sputnik = earth.stationFactory("Sputnik", "One of the oldest space stations")
  Dictionary.add_discovered_proper_noun(sputnik.name, sputnik)
  mall = earth.stationFactory("OrbitalMall", "A Modern trading space station")
  Dictionary.add_discovered_proper_noun(mall.name, mall)
  unionstation = venus.stationFactory("UnionHall", "Union run trade and service station")
  Dictionary.add_discovered_proper_noun(unionstation.name, unionstation)
  
  houston =  earth.cityFactory("Houston", "Main space port for Earth, based in old continental America")
  Dictionary.add_discovered_proper_noun(houston.name, houston)
  marsport = mars.cityFactory("Dundarach", "Only space port for Mars, sometimes referred to as Marsport")
  Dictionary.add_discovered_proper_noun(marsport.name, marsport)
  nicosia = mars.cityFactory("Nicosia", "Now deserted city, location of the first Mars independence revolt.")
  ImageWindow.register("Nicosia",{:centre => "ruinedcity22"})
  Dictionary.add_discovered_proper_noun(nicosia.name, nicosia)
  venutia = venus.cityFactory("Venutia", "Disused space port for Venus")
  Dictionary.add_discovered_proper_noun(venutia.name, venutia)
  
  
  trader = mall.traderFactory("Buffet", :Industries, "Trading in ice cream components")
  trader2 = mall.traderFactory("Amstrad", :Intergalactic, "Trading in faulty computing equipment")
  garage = unionstation.garageFactory("Minestar", :Garages, "Service garage")
  tuckshop = unionstation.traderFactory("Union", :Trading, "Miner's Union run station")
  #garage = sputnik.garageFactory("Minestar", :Garages, "Service garage")
  item = Item.new("blackberries", "A juicy forest fruit", :commodity, [:foodstuff])
  Dictionary.add_discovered_item(item.name, item)  
  trader.add_sink_trade(item)
  item = Item.new("choclate chips", "Confectionery additions", :commodity, [:foodstuff])
  Dictionary.add_discovered_item(item.name, item)  
  trader.add_sink_trade(item)
  wafercones = Item.new("wafer cones", "Confectionery containers", :commodity, [:foodstuff])
  Dictionary.add_discovered_item(wafercones.name, wafercones)
  titanium = Item.new("titanium alloy", "Pure deep mined titanium", :rare)
  Dictionary.add_discovered_item(titanium.name, titanium)
  trader2.add_source_trade(wafercones)
  vmu = Organisation.new("Venus Mining Union", "Keeping the red flag flying!", :public)
  tuckshop.set_owning_org vmu
  tuckshop.add_sink_trade(wafercones)
  tuckshop.add_source_trade(titanium,1)
  
  info "tuckshop owning org #{tuckshop.owning_org}"
  
  garage.set_owning_org vmu
  garage.add_service_module(GovTorpedo)
  garage.add_service_module(HeatShieldModule,1)
  
  eye = Item.new("horus eye", "Alien artifact, possibly of Martian origin", :unique, [:controlled, :alien])
  Dictionary.add_discovered_item(eye.name, eye)

  trader2.add_source_trade(eye,1)
      
  Dictionary.add_double_discovered_proper_noun(trader.name, trader.index_name, trader)
  Dictionary.add_double_discovered_proper_noun(trader2.name, trader2.index_name, trader2)
  Dictionary.add_double_discovered_proper_noun(garage.name, garage.index_name, garage)
  Dictionary.add_double_discovered_proper_noun(tuckshop.name, tuckshop.index_name, tuckshop)

  freemars = Organisation.new("Free Mars", "Independence for Mars!", :secret)
  freemars.add_message(:visit_mars,"New Nicosia is still desolate from when Earth forces levelled it after the rebellion.\
 If you want to know more about what's happening to Mars, talk to our contact on Earth.")
  pers = houston.contactFactory(:m, "Prof.", "Nordstrum", "Alien artifact trader", freemars, 1)
  pers.add_details(:interest => :alien, :talk => :war)

  listeningPost.add_updated_desc(2, "Earth military control listening post", freemars)
  listeningPost.add_death_listener(freemars)
  
  nicosia.add_visit_trigger(freemars, 1, :visit_mars)

  ship = ShipRegistry.register_ship("ProjectX",sputnik.surfacePoint)
  Dictionary.add_discovered_proper_noun(ship.name, nil) #should be an sgo
  ShipSystem.christen(ship)
  
  ship.push_mail(SystemGhost.welcome, "ghost")
  
  ship.trade.cargo << Consignment.new(wafercones,trader2)
  
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
        para "- Try 'status' to find out more commands\n", :stroke => azure
        para "- Type space or tab to complete any command\n", :stroke => azure
        para "- Your vessel is in an old space station\n", :stroke => azure
        para "- The first command to try is probably 'undock'\n", :stroke => aquamarine

      }
      keypress { | k| 
          poop.close
      }
    end
  end
 end 
 
   def self.loadGalaxy 
      mygalaxy = nil
      mysol = nil
      myplanet = nil
      myorg = nil
      mysat = nil
      mygarage = nil
      mytrader = nil
      desc = nil
      id = nil
      File.open("stellar.json") do |file|
         galaxies = JSON::load(file)
         galaxies.each do |galaxy_name, galaxy|
            galaxy.each do |content_type, stars |
               if content_type == "desc"
                  mygalaxy = Galaxy.new(galaxy_name, stars)
                  Dictionary.add_discovered_proper_noun(mygalaxy.name, mygalaxy)
               else
                  stars.each do |star_name, star |
                     star.each do |content_type, planets |
                        if content_type == "desc"
                           mysol = mygalaxy.starFactory(star_name, planets)
                           Dictionary.add_discovered_proper_noun(mysol.name, mysol)
                        else
                           planets.each do |planet_name, planet |
                              planet.each do |content_type, sat_or_cit |
                                 if content_type == "desc"
                                    myplanet = mysol.planetFactory(planet_name, sat_or_cit)
                                    Dictionary.add_discovered_proper_noun(myplanet.name, myplanet)
                                 elsif content_type == "cities"
                                    sat_or_cit.each do |city_name, city_desc |
                                       mycity = myplanet.cityFactory(city_name, city_desc)
                                       Dictionary.add_discovered_proper_noun(mycity.name, mycity)
                                    end
                                 elsif content_type == "stations"
                                    sat_or_cit.each do |sat_name, sat |
                                       sid = nil
                                       sat.each do |content_type, business |
                                          end_name = nil
                                          if content_type == "id"
                                             sid = business
                                          elsif content_type == "desc"
                                             mysat = myplanet.stationFactory(sat_name, business, sid)
                                             Dictionary.add_discovered_proper_noun(mysat.name, mysat)
                                          elsif content_type == "traders"
                                             business.each do |trader_name, trader|
                                                trader.each do |content_type, content|
                                                   desc = content if content_type == "desc"
                                                   id = content if content_type == "id"
                                                   end_name = content.to_sym if content_type == "end_name"
                                                end   
                                                mytrader = mysat.traderFactory(trader_name, end_name, desc, id)
                                                Dictionary.add_double_discovered_proper_noun(mytrader.name, mytrader.index_name, mytrader)
                                             end
                                          elsif content_type == "garages"
                                             business.each do |garage_name, garage|
                                                garage.each do |content_type, content|
                                                   desc = content if content_type == "desc"
                                                   id = content if content_type == "id"
                                                   end_name = content.to_sym if content_type == "end_name"
                                                end   
                                                mygarage = mysat.garageFactory(garage_name, end_name, desc, id)   
                                                Dictionary.add_double_discovered_proper_noun(mygarage.name, mygarage.index_name, mygarage)
                                             end
                                          end
                                       end

                                    end   
                                 elsif content_type == "structures"
                                    sat_or_cit.each do |struc_name, structure |  
                                       desc = nil
                                       toughness = nil
                                       sid = nil
                                       subtype = nil
                                       structure.each do |content_type, content|
                                          desc = content if content_type == "desc"
                                          alt_desc = content if content_type == "alt_desc"
                                          sid = content if content_type == "id"
                                          toughness = content if content_type == "toughness"
                                          subtype = content.to_sym if content_type == "subtype"
                                       end
                                       mystruct = myplanet.structureFactory(struc_name, desc, toughness, sid, subtype)
                                       Dictionary.add_discovered_proper_noun(mystruct.name, mystruct)
                                    end
                                 end
                              end
                           end   
                        end
                     end   
                  end
               end      
            end
         end
      end
   end
 
   def self.loadOrgs
      File.open("organisation.json") do |file|
          orgs = JSON::load(file)
          orgs.each do |org_name, org|
            desc = nil
            privacy = nil
            id = nil
            org.each do |content_type, content|
               desc = content if content_type == "desc"
               id = content if content_type == "id"
               privacy = content.to_sym if content_type == "privacy"
            end
            myorg = Organisation.new(org_name,desc,privacy,id)
            info "#{myorg.name} - #{myorg.desc}"
          end  
      end
   end
   
   def self.loadPeople
      File.open("people.json") do |file|
          people = JSON::load(file)
          people.each do |person_name, person|
            desc = nil
            sex = nil
            title = nil
            person.each do |content_type, content|
               desc = content if content_type == "desc"
               sex = content.to_sym if content_type == "sex"
               title = content if content_type == "title"
            end
            myperson = Person.new(sex, title, person_name, desc)
            info "#{myperson.name} - #{myperson.desc}"
          end  
      end
   end
 
   def self.loadItems   
      myitem = nil
      File.open("item.json") do |file|
          items = JSON::load(file)
          items.each do |item_name, item|
            desc = nil
            commonality = nil
            tags = nil
            id = nil
            item.each do |content_type, content|
               desc = content if content_type == "desc"
               id = content if content_type == "id"
               commonality = content.to_sym if content_type == "commonality"
               tags_as_string = content if content_type == "tags"
               tags = tags_as_string.collect{|tag| tag.to_sym} unless tags_as_string.nil?
            end
            myitem = Item.new(item_name,desc,commonality,tags,id)
            Dictionary.add_discovered_item(myitem.name, myitem)
            info "#{myitem.name} - #{myitem.desc}"
          end  
      end
   end
end