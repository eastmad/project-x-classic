class MediaManager
   @@media_package = {
      :drive => {:entry_anim => :hyper, :sound => 3},
      :plot_course => {:entry_anim => :plot, :sound => 2},
      :travel => {:entry_anim => :stars, :sound => 3},
      :orbit => {:entry_anim => :stars, :sound => 3},
      :docking => {:entry_anim => :stars, :sound => 3},
      :land => {:entry_anim => :stars, :sound => 3},
      :describe => {:entry_anim => :solar_system, :exit_anim => :solar_system, :sound => 2},
      :atmosphere => {:entry_anim => :stars, :sound => 3},
      :trade => {:entry_anim => :crates, :exit_anim => :crates, :sound => 2},
   }
   
   def self.show_media(im_win, pack_id, locationPoint)
      package_hash = @@media_package[pack_id]
      SoundPlay.play_sound(package_hash[:sound])
      
      
      exit = package_hash[:exit_anim]
      exit = ImageWindow.find_id locationPoint if exit.nil?
      #exit = locationPoint.body.image unless locationPoint.body.image.nil?

      im_win.set_animation(package_hash[:entry_anim],exit)
   end
end

