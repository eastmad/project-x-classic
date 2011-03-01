Shoes.app do
  @s0 = stack do
    background red
    100.times do
      para "yay"
    end
  end
  @s = stack do
    style(:attach => Window, :top => height - 100)
    background lightblue
    para app.width
    para app.height
  end
end
