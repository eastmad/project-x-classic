require 'purple_shoes'

Shoes.app(:title => "The Owner", :width => 1024, :height => 600) do
  
  poop =  window(:title => "Welcome to Project-X", :width => 512, :height => 250)  do
    @myline = Myline.new
    @p = nil
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
        @p = para strong("para1"),"weak", :stroke => azure
      }
      #@p1.contents[1].replace("strong")
      flow{
        #@p1.contents[1].replace("strong")
        button(:right => 10, :text =>  "Right") do
          info "push"
          @p.contents[1].replace "strong"
          @p.contents[0].replace "mega"
        end
        button(:right => 100, :text =>  "Left") do
          info "push"
          @p.contents[0].replace "mega"
        end
      }
    end
  end
end

class Myline

  attr_accessor :line
  
  def alterLeft w
    @line.contents[0].replace(w)
    info "alterLeft with #{w} makes #{@line}"
  end
  
  def alterRight w
    @line.contents[1].replace w
    info "alterRight with #{w} makes #{@line}"
  end
end
