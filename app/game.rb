# base class all games inherit from
class Game
  def tick(args)
    if args.inputs.keyboard.key_down.escape || args.inputs.controller_one&.key_down&.select
      args.state.current_game = Home.new
    end
  end
end
