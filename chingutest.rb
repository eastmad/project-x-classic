require 'chingu'
#require 'texplay'
require_relative "input_state"
require_relative "control_systems/dictionary"
require_relative "display_response"
require_relative "control_systems/grammar_tree"
require_relative "interface/system_message"
require_relative "key_handler"
include Gosu
include Chingu

#
# We use Chingu::Window instead of Gosu::Window
#


module ColourMap
  MAP = {:white => 0xffffffff, :red => 0xffff0000,
    :black => 0xff000000, :blue => 0xff0000ff,
    :yellow => 0xffffff00, :green => 0xff00ff00, :darkergreen => 0xff00dd00,
    :detailviewblue => 0xff2222aa, :commandviewblue => 0xff142a2a,
    :short => 0xffffddaa, :proper_noun => 0xffaaffaa,
    :item => 0xffaaaaff, :none => 0xffdd8888, :verb => 0xffffff00}
  
  SHADOWMAP = {:short => 0xff887755, :proper_noun => 0xff558855,
    :item => 0xff555588, :none => 0xff774444, :verb => 0xff888800}
  
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
    super     # This is always needed if you override Window#initialize
    #
    # Player will automatically be updated and drawn since it's a Chingu::GameObject
    # You'll need your own Chingu::Window#update and Chingu::Window#draw after a while, but just put #super there and Chingu can do its thing.
    #
    
    verticals = {:v0 => 0, :v1 => width/2, :vmax => width - 1}
    horizontals = {:h0 => 0, :h1 => height/3, :h2 => (2*height)/3, :h3 => height/2, :hmax => height}
    MiniMapView.create(verticals[:v0],horizontals[:h1],verticals[:v1],horizontals[:hmax])
    @pv = PictureView.create(verticals[:v0],horizontals[:h0],verticals[:v1],horizontals[:h3])
    @civ = CommandInputView.create(verticals[:v1],horizontals[:h0],verticals[:vmax],horizontals[:h1])
    @crv = CommandResponseView.create(verticals[:v1],horizontals[:h1],verticals[:vmax],horizontals[:h2])
    @dv =DetailView.create(verticals[:v1],horizontals[:h2],verticals[:vmax],horizontals[:hmax]);
    @pv.set_image()
    @kh = KeyHandler.new
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
  
    @kh.set_civ(@civ)
    @kh.process ret
    
    #@civ.active_word_part = [:yellow,ret] unless ret.nil?
  end
  
  def draw
    super
  end
end


class MiniMapView < Chingu::GameObject
  
  def initialize(x0,y0,x1,y1)
    super({})
    @rect = Rect.new(x0, y0, x1, y1)
  end
  
  def draw    
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
  
  attr_accessor :suggestion, :complete_words, :active_word_part, :key_hints
  
  def initialize(x0,y0,x1,y1)
    super({})
    @rect = Rect.new(x0, y0, x1 - x0, y1 - y0)
    @font = Gosu::Font.new($window, "Gosu::default_font_file", 24)
    @suggestion = [:verb, ""]
    @complete_words = []
    @active_word_part = [:verb,""]
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
    
    @key_space.draw(@rect.x + 20, @rect.y + 50, 1) if @key_hints == :word
    @key_arrow.draw(@rect.x + 20 + @key_space.width + 5, @rect.y + 50, 1) if @key_hints == :word
    @key_return.draw(@rect.x + 20 + @key_space.width + @key_arrow.width + 10, @rect.y + 50, 1) if @key_hints == :next
    @key_alpha.draw(@rect.x + 20 + @key_space.width + @key_arrow.width + @key_return.width + 15, @rect.y + 50, 1) unless @key_hints == :word
  end  
end

class CommandResponseView < Chingu::GameObject
  
  def initialize(x0,y0,x1,y1)
    super({})
    @rect = Rect.new(x0, y0, x1 - x0, y1 - y0)
  end

  def draw
    $window.fill_rect(@rect, ColourMap.get_colour(:green))
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