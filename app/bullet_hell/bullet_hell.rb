class BulletHell < Game
  NAME = "Bullet Hell"

  def tick(args)
    super(args)
    args.outputs.primitives << [20, 20, NAME, *WHITE].label
  end
end
