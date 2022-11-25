class Pong < Game
  NAME = "Pong"

  def tick(args)
    super(args)
    args.outputs.labels << [20, 20, NAME, *WHITE]
  end
end
