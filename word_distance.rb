#word grouping

require_relative "control_systems/dictionary"

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
