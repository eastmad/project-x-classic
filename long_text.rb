class LongText
    
    @@txt = {:war =>
"\"When the war came, it started with one unexpected act of independence. When the war stopped, \
it ended with the collapse of both economies. The Earth elite left their listening posts and \
their system of government.\"",
		:mining_standards => "\"Mining is hard on the people here, but with strong representation, the conditions will slowly improve.\""
    }
    
    def self.txt access
       @@txt[access] 
    end
end