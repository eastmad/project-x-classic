class LongText
    
    @@txt = {
      :war =>
"\"When the war came, it started with one unexpected act of independence. When the war stopped, \
it ended with the collapse of both economies. The Solar government left their listening posts and \
their system of government. Many rebels fled to Mercury.\"",
		:mining_standards =>
"\"Mining is hard on the people here, but with strong representation, the conditions will slowly \
improve. We produce the minerals needed for heat shields, which can be made available by the Venus Mining Union.\"",
		:tourism =>
"\"I hope you enjoy your visit to this peaceful city. We would advise you not to stray too \
far from the areas designated safe by the Solar government. Peace and harmony.\"",
		:gate =>
"\"The life here is difficult, I just maintain the gate. They mainly leave us alone out here, that \
attracts a certain type of outlaw. To use the gate you will need a jump pod.\""
    }
    
    def self.txt access
       @@txt[access] 
    end
end