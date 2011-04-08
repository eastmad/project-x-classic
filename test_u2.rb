

Shoes.app(:title => "The Owner", :width => 1024, :height => 600) do
  
  poop =  window("Welcome to Project-X", :width => 512, :height => 250)  do
    background black
    stack do
      
      flow {
        caption "You are in control of the small vessel, project-x.\nWhatever you are looking for, it isn't in this solar system.", :stroke => white, :align => "center"
      }
      flow { 
        para "You start docked in an old space station.", :stroke => white, :align => "center"
      }
      flow {
        para "- The first command to try is probably 'launch'\n", :stroke => azure
        para "- Try 'summarize' and 'help' to find out more commands\n", :stroke => azure
        para "- Type space or tab to complete any command\n", :stroke => azure
      }
      flow{
        button(:right => 10, :text =>  "Start") do
          poop.close
        end
      }
    end
  end
end