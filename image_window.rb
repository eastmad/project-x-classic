class ImageWindow

   @@anims = {
   :plot => ["gifs/plot/1.gif","gifs/plot/2.gif","gifs/plot/3.gif","gifs/plot/4.gif","gifs/plot/5.gif","gifs/plot/6.gif","gifs/plot/7.gif","gifs/plot/8.gif","gifs/plot/9.gif","gifs/plot/10.gif","gifs/plot/11.gif","gifs/plot/12.gif","gifs/plot/13.gif","gifs/plot/14.gif","gifs/plot/15.gif","gifs/plot/16.gif","gifs/plot/17.gif","gifs/plot/18.gif","gifs/plot/19.gif","gifs/plot/20.gif"],
   :terre => ["gifs/terre/terre0.gif", "gifs/terre/terre1.gif", "gifs/terre/terre2.gif", "gifs/terre/terre3.gif", "gifs/terre/terre4.gif", "gifs/terre/terre5.gif", "gifs/terre/terre6.gif", "gifs/terre/terre7.gif", "gifs/terre/terre8.gif"],
   :hyper =>["gifs/hyper/hyper-1.gif", "gifs/hyper/hyper-2.gif", "gifs/hyper/hyper-3.gif", "gifs/hyper/hyper-4.gif", "gifs/hyper/hyper-5.gif", "gifs/hyper/hyper-6.gif", "gifs/hyper/hyper-7.gif", "gifs/hyper/hyper-8.gif", "gifs/hyper/hyper-9.gif", "gifs/hyper/hyper-10.gif"],
   :stars =>["gifs/stars/1.gif","gifs/stars/2.gif","gifs/stars/3.gif","gifs/stars/4.gif","gifs/stars/5.gif","gifs/stars/6.gif","gifs/stars/7.gif","gifs/stars/8.gif","gifs/stars/9.gif","gifs/stars/10.gif","gifs/stars/11.gif","gifs/stars/12.gif","gifs/stars/13.gif","gifs/stars/14.gif","gifs/stars/15.gif","gifs/stars/16.gif","gifs/stars/17.gif","gifs/stars/18.gif","gifs/stars/19.gif","gifs/stars/20.gif"],
   :station =>["gifs/station/Frame_0.gif", "gifs/station/Frame_1.gif","gifs/station/Frame_2.gif","gifs/station/Frame_3.gif","gifs/station/Frame_4.gif","gifs/station/Frame_5.gif"],
   :galaxy => ["gifs/galaxy.jpg"],
   :solar_system => ["gifs/solar-system.jpg"],
   :mars => ["gifs/mars-planet-water-nasa.jpg"],
   :venus => ["gifs/venus.jpg"],
   :city => ["gifs/cityport.jpg"],
   :planet => ["gifs/planet.jpg"],
   :ruinedcity => ["gifs/ruinedcity22.jpg"],
   :desertoutpost => ["gifs/desertoutpost.jpg"],
   :earth_atmosphere => ["gifs/atmosphere.jpg"],
   :atmosphere => ["gifs/Mars-Atmosphere.jpg"],
   :stationdocked =>["gifs/station-closeup.jpg"],
   :satellite =>["gifs/satellite.jpg"],
   :jumpgate => ["gifs/earth_jumpgate_tech.jpg"],
   :crates =>["gifs/crates.jpg"],
   :torpedo =>["gifs/torpedo.jpg"],
   }
   
   #prefer the last selection (ordered hash)
   @@sgo = {
      :Planet => {:orbit => :planet, :atmosphere => :atmosphere},
      :Star => {:outer => :solar_system},
      :Galaxy => {:centre => :galaxy, :outer => :galaxy},
      :SpaceStation=> {:surface => :stationdocked, :outer => :station, :centre => :stationdocked},
      :SmallStructure => {:centre => :satellite},
      :JumpGate => {:centre => :jumpgate},
      :City => {:centre => :city}
   }
   
   @@named = {}
  
   def self.to_file name
      "gifs/#{name}.jpg"
   end

   def self.register name, hash
      @@named.merge!({name.to_sym => hash})                                    
   end

   def self.find_id locPoint
      body = locPoint.body
      klassname = body.class.name.to_sym
      sgo_hash = @@sgo[klassname]
      sgo_hash[locPoint.band]

      if @@named[body.name.to_sym]
         val = @@named[body.name.to_sym][locPoint.band.to_sym]

         unless val.nil?
            @@anims.merge!({val.to_sym => ["gifs/#{val}.jpg"]})
            info @@anims
            info "val = #{val}"
            return val.to_sym unless val.nil?
         end   
      end   

      sgo_hash[locPoint.band.to_sym]
    end

   def initialize(anim_id)
      @ims = @@anims[anim_id]
      @frame_max = @ims.size
      @exit_anim_id = nil
      @frames_run = 0
   end

   def animate_image(frame_num)
     @frames_run += 1
     if (!@exit_anim_id.nil? and @frames_run >= @frame_max)
      set_animation(@exit_anim_id)
     end
     @ims[frame_num%@frame_max]
   end
   
   def first_image
      @ims[0]
   end
   
   def set_animation(anim_id, exit_anim_id = nil)
      @ims = @@anims[anim_id]
      @frame_max = @ims.size
info "anim_id = #{anim_id}, exit anim = #{exit_anim_id}"      
      @exit_anim_id = exit_anim_id
      @frames_run = 0
   end
end