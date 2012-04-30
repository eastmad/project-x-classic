#small white dot around screen
Shoes.app(:width => 250, :height => 250, :title => "ProjectX simple graphics test") {
   background black
   image "gifs/terre_noir.jpg"
   stroke white
   nofill
   
   two_dots()  
}

def two_dots()
   tx = txtravel = 10
   ty = tytravel = 10
   ty2 = self.height - 20
   travel = 2
   
   topsq = rect txtravel, ty, 2, 2
   bottomsq = rect self.width - 20 - txtravel, ty2, 2, 2
   animate(20) { |frame|

      #rect self.width - 10, 10, 2, 2
      txtravel += travel
      stroke white
      topsq.move txtravel, ty
      bottomsq.move self.width - 20 - txtravel, ty2
      #rect tx + 5, ty, 2, 2
      travel *= -1 if txtravel < 10 || txtravel > self.width - 20
   }
end
   
