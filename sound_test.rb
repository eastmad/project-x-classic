require "sound_play"

Shoes.app do
  sounds = Array.new
  num = 1
  
  while File.exists?(SoundPlay.load_sound(num)) do    
     s = SoundPlay.load_sound(num)
     sound = video s          
     info "sound=#{sound.inspect}"
     SoundPlay.register_sound(sound)     
     num += 1
  end  
  SoundPlay.hide_sounds()
  info "Num=#{SoundPlay.num_sounds()}"
  
  button( "play sound0" ){ SoundPlay.play_sound(0)}
  button( "play sound1" ){ SoundPlay.play_sound(1)}
  button( "play sound2" ){ SoundPlay.play_sound(2)}
  button( "play sound3" ){ SoundPlay.play_sound(3)}
  button( "play sound4" ){ SoundPlay.play_sound(4)}
  button( "play sound5" ){ SoundPlay.play_sound(5)}
  button( "play sound6" ){ SoundPlay.play_sound(6)}
  button( "play sound7" ){ SoundPlay.play_sound(7)}
  button( "play sound8" ){ SoundPlay.play_sound(8)}
  button( "play sound9" ){ SoundPlay.play_sound(9)}
end