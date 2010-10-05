#image_stack

class ImageWindow

#   @@ims = ["gifs/terre0.gif", "gifs/terre1.gif", "gifs/terre2.gif", "gifs/terre3.gif", "gifs/terre4.gif", "gifs/terre5.gif", "gifs/terre6.gif", "gifs/terre7.gif", "gifs/terre8.gif"]
   @@ims = ["gifs/bomb.gif", "gifs/bomb2.gif", "gifs/bomb3.gif", "gifs/bomb4.gif", "gifs/bomb5.gif", "gifs/bomb6.gif", "gifs/bomb7.gif", "gifs/bomb8.gif"]
   

   def self.animate_image(imstack, frame_num)
     imstack.clear { image @@ims[frame_num%8] }                     
   end   
end