#test steallar.json

require "json"

require_relative "simple_object_world/simple_body"
require_relative "simple_object_world/trustee"
require_relative "simple_object_world/trust_holder"
require_relative "simple_object_world/city"
require_relative "simple_object_world/simple_game_object"
require_relative "simple_object_world/contact"
require_relative "simple_object_world/trader"
require_relative "simple_object_world/trade"
require_relative "simple_object_world/location_point"
require_relative "simple_object_world/location_link"


mygalaxy = nil
mysol = nil
myplanet = nil
myorg = nil
mysat = nil
myitem = nil
mygarage = nil
mytrader = nil
desc = nil

File.open("item.json") do |file|
    items = JSON::load(file)
    items.each do |item_name, item|
    	desc = nil
    	commonality = nil
    	tags = nil
    	item.each do |content_type, content|
    		desc = content if content_type == "desc"
    		commonality = content.to_sym if content_type == "commonality"
    		tags = content if content_type == "tags"
    	end
    	myitem = Item.new(item_name,desc,commonality,tags)
    	puts "#{myitem.name} - #{myitem.desc}"
    end	
end

File.open("organisation.json") do |file|
    orgs = JSON::load(file)
    orgs.each do |org_name, org|
    	desc = nil
    	privacy = nil
    	org.each do |content_type, content|
    		desc = content if content_type == "desc"
    		privacy = content.to_sym if content_type == "privacy"
    	end
    	myorg = Organisation.new(org_name,desc,privacy)
    	puts "#{myorg.name} - #{myorg.desc}"
    end	
end

File.open("stellar.json") do |file|
    galaxies = JSON::load(file)
    galaxies.each do |galaxy_name, galaxy|
    	galaxy.each do |content_type, stars |
    		if content_type == "desc"
			mygalaxy = Galaxy.new(galaxy_name, stars)
			puts "#{mygalaxy.name} - #{mygalaxy.desc}"
		else
			stars.each do |star_name, star |
				star.each do |content_type, planets |
					if content_type == "desc"
						mysol = mygalaxy.starFactory(star_name, planets)
						puts "#{mysol.name} - #{mysol.desc}"
					else
						planets.each do |planet_name, planet |
							planet.each do |content_type, sat_or_cit |
								if content_type == "desc"
									myplanet = mysol.planetFactory(planet_name, sat_or_cit)
									puts " #{myplanet.name} - #{myplanet.desc}"
								elsif content_type == "cities"
									sat_or_cit.each do |city_name, city_desc |
										mycity = myplanet.cityFactory(city_name, city_desc)
										puts "  #{mycity.name} - #{mycity.desc}"
									end
								elsif content_type == "satellites"
									sat_or_cit.each do |sat_name, sat |
										sat.each do |content_type, business |
											end_name = nil
											if content_type == "desc"
												mysat = myplanet.stationFactory(sat_name, business)
												puts "  #{mysat.name} - #{mysat.desc}"
											elsif content_type == "traders"
												business.each do |trader_name, trader|
													trader.each do |content_type, content|
														desc = content if content_type == "desc"
														end_name = content.to_sym if content_type == "end_name"
													end	
													mytrader = mysat.traderFactory(trader_name, end_name, desc)										
													puts "   #{mytrader} - #{mytrader.desc}"
												end
											elsif content_type == "garages"
												business.each do |garage_name, garage|
													garage.each do |content_type, content|
														desc = content if content_type == "desc"
														end_name = content.to_sym if content_type == "end_name"
													end	
													mygarage = mysat.garageFactory(garage_name, end_name, desc)										
													puts "   #{mygarage} - #{mygarage.desc}"
												end
											end
										end
										
									end	
								elsif content_type == "structures"
									sat_or_cit.each do |struc_name, structure |	
										desc = nil
										toughness = nil
										structure.each do |content_type, content|
											desc = content if content_type == "desc"
											alt_desc = content if content_type == "alt_desc"
											toughness = content if content_type == "toughness" 
										end
										mystruct = myplanet.structureFactory(struc_name, desc, toughness)
										puts "  #{mystruct.name} - #{mystruct.desc}, tghns = #{toughness}"
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