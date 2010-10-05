

Shoes.app do
  @hand = image "http://hacketyhack.net/images/design/Hand-256x256.png"
  image "http://hacketyhack.net/images/design/Hand-Green-256x256.png",
    :attach => @hand, :top => 40, :left => 50

  motion do |x, y|
    @hand.move x, y
  end
end

