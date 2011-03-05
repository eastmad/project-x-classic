class LongText
    
    @@txt = {:war =>
"\"When the war came, it started with one unexpected act of independence. When the war stopped, \
it ended with the collapse of both economies. The Earth elite left their listening posts and \
their system of government.\""
    }
    
    def self.txt access
       @@txt[access] 
    end
end