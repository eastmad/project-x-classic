class MediaManager
   @@media_package = {
      :drive => {:entry_anim => :hyper, :exit_anim => :terre, :sound => 3},
      :plot_course => {:entry_anim => :plot, :sound => 3},
      :travel => {:entry_anim => :stars, :exit_anim => :terre, :sound => 3},
      :orbit => {:entry_anim => :stars, :exit_anim => :terre, :sound => 3},
      :docking => {:entry_anim => :stars, :exit_anim => :station, :sound => 3},
      :describe => {:entry_anim => :solar_system, :exit_anim => :solar_system, :sound => 3},
   }
   
   def self.show_media(im_win, pack_id)
      package_hash = @@media_package[pack_id]
      SoundPlay.play_sound(package_hash[:sound])
      if package_hash.key? :exit_anim
         im_win.set_animation(package_hash[:entry_anim],package_hash[:exit_anim])
      else
         im_win.set_animation(package_hash[:entry_anim])
      end
   end
end
