# base class all games inherit from
class Game
  def initialize
    current_index = $gtk.args.state.current_game_index
    $gtk.reset
    $gtk.args.state.current_game_index = current_index
  end

  def tick(args)
    if args.inputs.keyboard.key_down.h || args.inputs.controller_one&.key_down&.select
      args.state.current_game = Home.new
    end
  end
end
