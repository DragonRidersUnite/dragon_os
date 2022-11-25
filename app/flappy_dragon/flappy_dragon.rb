class FlappyDragon < Game
  NAME = "Flappy Dragon"

  def tick(args)
    super(args)
    args.outputs.primitives << [20, 20, NAME, *WHITE].label
  end
end
