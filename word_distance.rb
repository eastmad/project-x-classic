#word grouping
require "json"
require_relative "control_systems/dictionary"
require_relative "game_start"
require_relative "simple_object_world/simple_body"
require_relative "simple_object_world/trustee"
require_relative "simple_object_world/trust_holder"
require_relative "simple_object_world/city"
require_relative "simple_object_world/simple_game_object"
require_relative "simple_object_world/trade"
require_relative "simple_object_world/trader"
require_relative "simple_object_world/location_point"
require_relative "simple_object_world/location_link"

GameStart.loadGalaxy
commandlist = []
nounlist = []

Dictionary.all_words.each do | word |
  commandlist << word[:word] if word[:grammar] == :verb
  nounlist << word[:word] if word[:grammar] == :proper_noun
end

#reorder alphabetically
commandlist.sort!
nounlist.sort!

#list words with same letters

last_word = ""

commandlist.each do | word |
  if word[0] == last_word[0]
    puts "#{last_word}, #{word}\n"
  end
  
  last_word = word
end

puts ("\n\n")

nounlist.each do | word |
  if word[0] == last_word[0]
    puts "#{last_word}, #{word}"
  end
  
  last_word = word
end
