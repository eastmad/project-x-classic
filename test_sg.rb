#small white dot around screen
Shoes.app(:width => 250, :height => 250, :title => "ProjectX simple graphics test") {
   anim_control = {}
   
   #stroke white
   nofill
   
   def star_shift_left(star_set, ac)
      ac[:next] = :rayline
      background black
      anim_block = animate(20) do |frame|
         
         star_set.each_index do |i|
            star_set[i].show
            star_set[i].move star_set[i].left - 2, star_set[i].top
            
            star_set[i].move star_set[i].left - 3, star_set[i].top if i%3 == 0
            
            star_set[i].move star_set[i].left - 4, star_set[i].top if i%4 == 0
            
         end
         ac[:status] = :stop if frame > 50
      end
      ac[:anim_block] = anim_block
   end

   def rayline(star_set, ac)
      centre_x = self.width/2
      centre_y = self.height/2
      
      ratio = 0.0
      
      info "x,y = #{centre_x},#{centre_y}"
      ac[:next] = :two_dots
      anim_block = animate(20) do |frame|
         
         star_set.each_index do |i|
            star_set[i].show
            ratio =   (centre_y - star_set[i].top).to_f / (centre_x - star_set[i].left).to_f
            info " x = #{star_set[i].left} y= #{star_set[i].top}, rat = #{ratio}"
            if ((star_set[i].left < centre_x) and (star_set[i].top <= centre_y) and (star_set[i].top >= star_set[i].left))
               line star_set[i].left, star_set[i].top, 0, centre_y -  (ratio * centre_x)
            elsif ((star_set[i].left < centre_x) and (star_set[i].top <= centre_y) and (star_set[i].top < star_set[i].left))
               line star_set[i].left, star_set[i].top, centre_x - (centre_y / ratio), 0   
            elsif ((star_set[i].left >= centre_x) and (star_set[i].top <= centre_y) and (star_set[i].top < self.height - (star_set[i].left*self.height)/self.width))
               line star_set[i].left, star_set[i].top, self.width, centre_y +  (ratio * centre_x)
            elsif ((star_set[i].left >= centre_x) and (star_set[i].top <= centre_y) and (star_set[i].top >= self.height - (star_set[i].left*self.height)/self.width))
               line star_set[i].left, star_set[i].top, self.width - (centre_y / ratio), 0   
            elsif ((star_set[i].left >= centre_x) and (star_set[i].top > centre_y) and (star_set[i].top >= star_set[i].left))
               line star_set[i].left, star_set[i].top, centre_x + (centre_y / ratio), self.height
            elsif ((star_set[i].left >= centre_x) and (star_set[i].top > centre_y) and (star_set[i].top < star_set[i].left))
               line star_set[i].left, star_set[i].top, self.width, centre_y +  (ratio * centre_x)
            elsif ((star_set[i].left < centre_x) and (star_set[i].top > centre_y) and (star_set[i].top < self.height - (star_set[i].left*self.height)/self.width))
               line star_set[i].left, star_set[i].top, 0, centre_y -  (ratio * centre_x)
            elsif ((star_set[i].left < centre_x) and (star_set[i].top > centre_y) and (star_set[i].top > self.height - (star_set[i].left*self.height)/self.width))
               line star_set[i].left, star_set[i].top, centre_x + (centre_y / ratio), self.height
   
            #elsif (star_set[i].left > star_set[i].top) and (star_set[i].top > (self.height - (star_set[i].left/self.width)))
            #   line star_set[i].left, star_set[i].top, self.width, (self.width / ratio)
            #elsif (star_set[i].left <= star_set[i].top) and (star_set[i].top >= self.height - (star_set[i].left/self.width))
            #   line star_set[i].left, star_set[i].top,  self.width - (ratio * self.width), self.height 
            #else line star_set[i].left, star_set[i].top, 0, self.height - (ratio * self.height) 
            end
         end
         ac[:status] = :stop if frame > 50
      end
      ac[:anim_block] = anim_block
   end

   def two_dots(star_set, ac)
      tx = txtravel = 10
      ty = tytravel = 10
      ty2 = self.height - 20
      travel = 2
      stroke lime
      image "gifs/terre_noir.jpg"
      topsq = arrow txtravel, ty, 2, 2
      bottomsq = arrow self.width - 20 - txtravel, ty2, 2, 2
      ac[:next] = :starshift
      
      anim_block = animate(20) do |frame|
   
         #rect self.width - 10, 10, 2, 2
         txtravel += travel
         topsq.move txtravel, ty
         bottomsq.move self.width - 20 - txtravel, ty2
         #rect tx + 5, ty, 2, 2
         travel *= -1 if txtravel < 10 || txtravel > self.width - 20
      end
      ac[:anim_block] = anim_block
   end

   background black
   stroke white
   stars = []
   (1..30).each do | num |
      stroke rgb(130,160,190)
      stroke rgb(160,190,220) if num%3 == 0
      stroke white if num%4 == 0
      r = rect rand(2 * self.width),rand(self.height),1,1
      r.hide()
      stars << r
   end
  
   anim_hash = {:twodots => proc{two_dots(stars, anim_control)}, :starshift => proc{star_shift_left(stars, anim_control)}, :rayline => proc{rayline(stars, anim_control)}}
   
   info "twodots = #{anim_hash[:twodots]}"
   anim_hash[:twodots].call(stars, anim_control)
   every(1) do
      if anim_control[:status] == :stop
         anim_control[:anim_block].stop
         anim_hash[anim_control[:next]].call(stars, anim_control)
         anim_control[:status] = :go
      end   
   end
   
   keypress { |k|
      if (k == "1")
         info "key press 1 #{anim_control}"
         anim_control[:status] = :stop
      end   
   }   
}

   
