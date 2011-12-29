#test steallar.json

require "json"

File.open("stellar.json") do |file|
    galaxies = JSON::load(file)
    galaxies.each do |galaxy_name, galaxy|
    	puts "galaxy is #{galaxy_name}"
    	galaxy.each do |content_type, stars |
    		if content_type == "desc"
			puts "galaxy is #{stars}" 
		else
			stars.each do |star_name, star |
				puts "star name is #{star_name}"
				star.each do |content_type, planets |
					if content_type == "desc"
						puts "star is #{planets}" 
					else
						planets.each do |planet_name, planet |
							puts "planet name is #{planet_name}"
							planet.each do |content_type, sat_or_cit |
								if content_type == "desc"
									puts "planet is #{sat_or_cit}" 
								elsif content_type == "cities"
									sat_or_cit.each do |city_name, city_desc |
										puts "City #{city_name} is #{city_desc}"
									end
								elsif content_type == "satellites"
									sat_or_cit.each do |sat_name, sat_desc |
										puts "Satellite #{sat_name}  is #{sat_desc}"
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
