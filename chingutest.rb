require 'chingu'
#require 'texplay'
require_relative "input_state"
require_relative "control_systems/dictionary"
require_relative "control_systems/ship_system"
require_relative "display_response"
require_relative "control_systems/grammar_tree"
require_relative "interface/system_message"
require_relative "interface/response_line"
require_relative "interface/response_queue"
require_relative "key_handler"
require_relative "simple_object_world/simple_body"
require_relative "simple_object_world/trustee"
require_relative "simple_object_world/trust_holder"
require_relative "simple_object_world/simple_game_object"
require_relative "simple_object_world/location_point"
require_relative "simple_object_world/location_link"
require_relative "control_systems/dictionary"
require_relative "control_systems/grammar_tree"
require_relative "control_systems/ship_registry"
require_relative "control_systems/ship_system"
require_relative "control_systems/ship_data"
require_relative "control_systems/operation"
require_relative "control_systems/system_ghost"
require_relative "control_systems/system_trade"
require_relative "control_systems/system_power"
require_relative "control_systems/system_weaponry"
require_relative "control_systems/system_navigation"
require_relative "control_systems/system_communication"
require_relative "control_systems/system_security"
require_relative "control_systems/system_myself"
require_relative "control_systems/system_library"
require_relative "control_systems/system_module"
require_relative "minimap/mini_map"
include Gosu
include Chingu

#
# We use Chingu::Window instead of Gosu::Window
#

Operation.register_op :orbit, :navigation

module ColourMap
  MAP = {:white => 0xffffffff, :grey => 0xffaaaaaa, :red => 0xffff0000,
    :black => 0xff000000, :blue => 0xff0000ff,
    :yellow => 0xffffff00, :green => 0xff00ff00, :darkergreen => 0xff00dd00,
    :detailviewblue => 0xff2222aa, :commandviewblue => 0xff142a2a, :commandresponseblue => 0xff151526,
    :short => 0xffffddaa, :proper_noun => 0xffaaffaa,
    :item => 0xffaaaaff, :none => 0xffdd8888, :verb => 0xffffff00, :adjective => 0xffffff00}
  
  SHADOWMAP = {:white => 0xffffffff, :short => 0xff887755, :proper_noun => 0xff558855,
    :item => 0xff555588, :none => 0xff774444, :verb => 0xff888800, :adjective => 0xffffff00}
  
  COLOURS = {}
  
  module_function
  
  def get_map col
    MAP[col]
  end
  
  def get_shadow_map col
    SHADOWMAP[col]
  end
  
  def get_colour col
    return COLOURS[col] unless COLOURS[col].nil?
    
    COLOURS[col] = Gosu::Color.new(MAP[col])
  end
end

class Game < Chingu::Window

  def initialize
    super(945,545,false)     # This is always needed if you override Window#initialize
    self.caption = "Project X"
    #
    # Player will automatically be updated and drawn since it's a Chingu::GameObject
    # You'll need your own Chingu::Window#update and Chingu::Window#draw after a while, but just put #super there and Chingu can do its thing.
    #
    
    verticals = {:v0 => 0, :v1 => width/3, :vmax => width - 1}
    horizontals = {:h0 => 0, :h1 => height/7, :h2 => (2*height)/3, :h3 => height/2, :hmax => height}
    @mmv = MiniMapView.create(verticals[:v0],horizontals[:h1],verticals[:v1],horizontals[:hmax])
    @pv = PictureView.create(verticals[:v0],horizontals[:h0],verticals[:v1],horizontals[:h3])
    @civ = CommandInputView.create(verticals[:v1],horizontals[:h0],verticals[:vmax],horizontals[:h1])
    @crv = CommandResponseView.create(verticals[:v1],horizontals[:h1],verticals[:vmax],horizontals[:h2])
    @dv =DetailView.create(verticals[:v1],horizontals[:h2],verticals[:vmax],horizontals[:hmax]);
    @pv.set_image()
    @kh = KeyHandler.new
    rq = ResponseQueue.new
    @kh.set_civ(@civ)
    @kh.set_rq(rq)
    @crv.set_rq(rq)
    
    galaxy = Galaxy.new("MilkyWay", "The limit of exploration")
    Dictionary.add_discovered_proper_noun(galaxy.name, galaxy)
    sol = galaxy.starFactory("Sol", "Your home planet's sun")
    Dictionary.add_discovered_proper_noun(sol.name, sol)
    earth = sol.planetFactory("Earth","Your home planet")
    Dictionary.add_discovered_proper_noun(earth.name, earth)
  
    sputnik = earth.stationFactory("Sputnik", "One of the oldest space stations", :sputnik)
    Dictionary.add_discovered_proper_noun(sputnik.name, sputnik)
  
    @ship = ShipRegistry.register_ship("ProjectX",SpaceStation.find(:sputnik).surfacePoint)
    Dictionary.add_discovered_proper_noun(@ship.name, nil) #should be an sgo
    ShipSystem.christen(@ship)
    
    @mmv.set_ship(@ship)
    @kh.set_ship(@ship)
  end
  
  def button_down(id)
    c = button_id_to_char id
    
    unless c.nil?
      if (button_down?(Gosu::KbLeftShift) || button_down?(Gosu::KbRightShift))
        ret = (c.ord - 32).chr 
      else
        ret = c
      end
    else
      case id
        when Gosu::KbReturn
          ret = :return
        when Gosu::KbSpace
          ret = :space
        when Gosu::KbBackspace
          ret = :backspace
        when Gosu::KbF1
          ret = :f1 
        when Gosu::KbLeft
          ret = :left
        when Gosu::KbRight
          ret = :right
        when Gosu::KbUp
          ret = :up
        when Gosu::KbDown
          ret = :down
      end
    end
    
    begin
      @kh.process ret
    rescue => ex
      p "we blew key with #{ex}"
    end  
    
  end
  
  def draw
    super
  end
end


class MiniMapView < Chingu::GameObject
  
  def initialize(x0,y0,x1,y1)
    super({})
    @rect = Rect.new(x0, y0, x1, y1)
    @minimap = MiniMap.new(10,30,50)
  end
  
  def set_ship ship
    @ship = ship
  end
  
  def draw
    @minimap.set_location_point @ship.locationPoint
    $window.fill_rect(@rect, ColourMap.get_colour(:red), 0)
  end  
end

class PictureView < Chingu::GameObject
  
  def initialize(x0,y0,x1,y1)
    super({})
    @rect = Rect.new(x0, y0, x1 - x0, y1 - y0)
  end

  def set_image()
    @image = Gosu::Image.new($window, "gifs/terre_noir.jpg", false)
  end

  def draw
    $window.fill_rect(@rect, ColourMap.get_colour(:black), 0)
    @image.draw(@rect.x, @rect.y, ColourMap.get_map(:green))
  end  
end

class CommandInputView < Chingu::GameObject
  
  attr_accessor :suggestion, :complete_words, :active_word_part, :key_hints, :last_command
  
  def initialize(x0,y0,x1,y1)
    super({})
    @rect = Rect.new(x0, y0, x1 - x0, y1 - y0)
    @font = Gosu::Font.new($window, "Gosu::default_font_file", 24)
    @smallfont = Gosu::Font.new($window, "Gosu::default_font_file", 18)
    @suggestion = [:verb, ""]
    @complete_words = []
    @active_word_part = [:verb,""]
    @last_command = [:grey, "Waiting for command"]
    @key_space = Gosu::Image.new($window, "gifs/space-key.jpg", false)
    @key_alpha = Gosu::Image.new($window, "gifs/a-key.jpg", false)
    @key_arrow = Gosu::Image.new($window, "gifs/arrow-key.jpg", false)
    @key_return = Gosu::Image.new($window, "gifs/return-key.jpg", false)    
  end

  def draw
    $window.fill_rect(@rect, ColourMap.get_colour(:commandviewblue), 0)
    
    prompt = [:white,"> "]
    cursor = [:white,"_"]
    cursor_pos = 0
    entire_string = ""
    
    p "@suggestion = #{@suggestion}"
    p "@active_word_part = #{@active_word_part}"
    p "@complete_words = #{@complete_words}"
    p "state  = #{@key_hints}"
    
    @font.draw(prompt[1], @rect.x, @rect.y, 1, 1.0, 1.0, ColourMap.get_map(prompt[0]))
    entire_string += prompt[1]
    cursor_pos = @font.text_width(entire_string)
    
    @complete_words.each do |txt_arr|
      entire_string += "#{txt_arr[1]} "
      @font.draw(txt_arr[1], @rect.x + cursor_pos, @rect.y, 1, 1.0, 1.0, ColourMap.get_map(txt_arr[0]))
      cursor_pos = @font.text_width(entire_string)
    end
    
    entire_string += @active_word_part[1]
    @font.draw(@active_word_part[1], @rect.x + cursor_pos, @rect.y, 1, 1.0, 1.0, ColourMap.get_map(@active_word_part[0]))
    cursor_pos = @font.text_width(entire_string)

    suggest_complete = @suggestion[1][@active_word_part[1].length..-1]
    entire_string += suggest_complete
    @font.draw("#{suggest_complete}#{cursor[1]}", @rect.x + cursor_pos, @rect.y, 1, 1.0, 1.0, ColourMap.get_shadow_map(@suggestion[0]))
    cursor_pos = @font.text_width(entire_string)
    
    @key_space.draw(@rect.right - 40 - @key_alpha.width - @key_return.width - @key_arrow.width- @key_space.width, @rect.y + 50, 1) if @key_hints == :word
    @key_arrow.draw(@rect.right - 30 - @key_alpha.width - @key_return.width - @key_arrow.width, @rect.y + 50, 1) if @key_hints == :word
    @key_return.draw(@rect.right - 20 - @key_alpha.width - @key_return.width, @rect.y + 50, 1) unless @key_hints == :next
    @key_alpha.draw(@rect.right - 10 - @key_alpha.width, @rect.y + 50, 1) unless @key_hints == :word
    
    @smallfont.draw(@last_command[1], @rect.x, @rect.y + 50, 1, 1.0, 1.0, ColourMap.get_map(@last_command[0]))
  end  
end

class CommandResponseView < Chingu::GameObject
  attr_accessor :rl
  traits :timer
  
  def initialize(x0,y0,x1,y1)
    super({})
    @rect = Rect.new(x0, y0, x1 - x0, y1 - y0)
    @font = Gosu::Font.new($window, "Gosu::default_font_file", 24)
    @rl = [ResponseLine.new, ResponseLine.new, ResponseLine.new, ResponseLine.new, ResponseLine.new, ResponseLine.new, ResponseLine.new]
    every(1000) {
      unless @rq.peek.nil?     
        message = @rq.deq
  
        unless (message.flavour == :mail || message.flavour == :report)
          #@rl.each do |n|
          #   n.set_line @ap[n - 1]
          #end
          @rl[0].set_line message
         
        else
          #@ma.set_line message
        end 
      end
    }
  end
  
  def set_rq rq
    @rq = rq
  end

  def draw
    $window.fill_rect(@rect, ColourMap.get_colour(:commandresponseblue))
    l = 0
    @rl.each do |n|
      @font.draw(n.cursor, @rect.x, @rect.y + l, 1, 1.0, 1.0, ColourMap.get_map(:white))
      cursor_pos = @font.text_width(n.cursor)
      @font.draw(n.text, @rect.x + cursor_pos + 2, @rect.y + l, 1, 1.0, 1.0, ColourMap.get_map(:white))
      l += 20
    end
  end
  
 
end

class DetailView < Chingu::GameObject
  
  def initialize(x0,y0,x1,y1)
    super({})
    @rect = Rect.new(x0, y0, x1 - x0, y1 - y0)
  end
  
  def draw
    $window.fill_rect(@rect, ColourMap.get_colour(:detailviewblue), 0)
  end  
end


Game.new.show   # Start the Game update/draw loop!