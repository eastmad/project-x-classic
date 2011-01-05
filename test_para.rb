Shoes.app(:width => 550, :height => 300, :title => "ProjectX") {
   
   flow {
      @a = para strong("poo"), " la di da"
   }
   
   keypress { |k|
      @a.contents[1].replace(" la di di") if (k == :f1)
      
      @a.contents[0].replace("piss") if (k == :f2)
      
      @a.contents[0].replace("shit") if (k == :f3)
      
      @a.contents[1].replace(" la di da") if (k == :f4)

   }
}