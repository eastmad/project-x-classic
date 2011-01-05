class SoundPlay
   
   private_class_method :new
   @@sounds = Array.new
   PLAYSOUNDS = true
   
   def self.sound?
      LocalConfig::PLAYSOUNDS
   end
 
   def self.load_sound(sound_id)
      "wav/sf#{sound_id}.wav"
   end      
   
   def self.register_sound(sound)
      @@sounds << sound      
   end

   def self.hide_sounds()
      @@sounds.each { | sound | sound.style(:width => 0, :height => 0) }
   end
   
   def self.play_sound(sound)            
      @@sounds[sound].play if PLAYSOUNDS     
   end
   
   def self.num_sounds()
      @@sounds.size
   end
   
end
