#small white dot around screen


#need a bounding square
Shoes.app(:width => 250, :height => 250, :title => "ProjectX simple graphics test") {
   anim_control = {}
   
   #stroke white
   nofill
   resource_set  = {}
   
   def star_shift_left(star_set, ac, frame_max, rs)
      ac[:next] = :short_pause
      #background black
      anim_block = animate(20) do |frame|
         star_set.each_index do |i|
            star_set[i].show
            star_set[i].move star_set[i].left - 2, star_set[i].top
            
            star_set[i].move star_set[i].left - 3, star_set[i].top if i%3 == 0
            
            star_set[i].move star_set[i].left - 4, star_set[i].top if i%4 == 0
            bi = rs[:back_image]
            bi.move(rs[:back_image].left - 4, rs[:back_image].top)
         end
         ac[:status] = :stop if frame > frame_max
      end
      ac[:anim_block] = anim_block
   end

   def rayline(star_set, ac, frame_max, rs)
      centre_x = self.width/2
      centre_y = self.height/2
      
      ratio = 0.0
      
      info "x,y = #{centre_x},#{centre_y}"
      ac[:next] = :twodots
      anim_block = animate(20) do |frame|
         star_set.each_index do |i|
            star_set[i].show
            ratio =   (centre_y - star_set[i].top).to_f / (centre_x - star_set[i].left).to_f
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
            end
         end
         ac[:status] = :stop if frame > frame_max
      end
      ac[:anim_block] = anim_block
   end

   def short_pause(star_set, ac, frame_max, rs)
      ac[:next] = :rayline
      anim_block = animate(20) do |frame|
         ac[:status] = :stop if frame > frame_max
      end
      ac[:anim_block] = anim_block
   end

   def two_dots(star_set, ac, frame_max, rs)
      tx = txtravel = 10
      ty = tytravel = 5
      ty2 = self.height - 18
      travel = 2
      stroke lime
      topline = line tx, ty - 2, self.width - 24, ty - 2
      #back_image = image "gifs/terre_noir.jpg"
      topsq = rect txtravel, ty, 2, 2
      bottomsq = rect self.width - 20 - txtravel, ty2, 2, 2
      ac[:next] = :starshift
      rs[:topsq] = topsq
      rs[:bottpmsq] = bottomsq
      #rs[:back_image] = back_image
      
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
   back_image = image "gifs/terre_noir.jpg"
   resource_set[:back_image] = back_image
   stars = []
   (1..40).each do | num |
      stroke rgb(130,160,190)
      stroke rgb(160,190,220) if num%3 == 0
      stroke white if num%4 == 0
      r = rect rand(2 * self.width),rand(self.height),1,1
      #r.hide()
      stars << r
   end
  
   anim_hash = {:twodots => proc{two_dots(stars, anim_control, 50, resource_set)}, :starshift => proc{star_shift_left(stars, anim_control, 50, resource_set)}, :short_pause => proc{short_pause(stars, anim_control, 20, resource_set)}, :rayline => proc{rayline(stars, anim_control, 50, resource_set)}}
   
   info "twodots = #{anim_hash[:twodots]}"
   anim_hash[:twodots].call(stars, anim_control)
   every(1) do
      if anim_control[:status] == :stop
         anim_control[:anim_block].stop
         anim_hash[anim_control[:next]].call()
         anim_control[:status] = :go
      end   
   end
   
   keypress { |k|
      if (k == "1")
         anim_control[:status] = :stop
      end   
   }   
}

   
