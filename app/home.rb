class Home
  INPUT_TICK_DELAY = 8

  GAMES = [
    FlappyDragon,
    Pong,
    BulletHell,
  ]

  def initialize
    $gtk.stop_music
  end

  def tick(args)
    margin = 64

    args.state.ticks_since_last_input ||= 0
    args.state.current_game_index ||= 0
    args.outputs.solids << [0, 0, args.grid.w, args.grid.h, *WHITE]
    args.outputs.labels  << [margin, args.grid.h - margin, 'DragonOS', 5, 0, *BLACK]
    args.outputs.labels  << [margin, 84, 'Select a game to play', 2, 0, *BLACK]

    control_text = "Return home with #{args.inputs.controller_one ? 'SELECT (or H)' : 'H' } at anytime"
    args.outputs.labels  << [args.grid.w - 80, 84, control_text, 0, 2, *BLACK]
    time = Time.now
    args.outputs.labels  << [args.grid.w - 64, args.grid.h - margin, "#{time.hour}:#{time.min.to_s.rjust(2, '0')}", 2, 1, *BLACK]

    confirm_keys = [:z, :enter, :space]
    if confirm_keys.any? { |k| args.inputs.keyboard.key_down.send(k) } || (args.inputs.controller_one&.key_down&.a)
      args.state.current_game = GAMES[args.state.current_game_index].new
      return
    end

    args.outputs.lines << [ 120, 160, args.grid.w - 120, 160, *BLACK]

    ready_for_input = args.state.ticks_since_last_input > INPUT_TICK_DELAY
    if ready_for_input
      if args.inputs.left
        args.state.current_game_index -= 1
        args.state.ticks_since_last_input = 0
      elsif args.inputs.right
        args.state.current_game_index += 1
        args.state.ticks_since_last_input = 0
      else
        args.state.ticks_since_last_input += 1
      end
    else
      args.state.ticks_since_last_input += 1
    end

    if args.state.current_game_index >= GAMES.length
      args.state.current_game_index = 0
    end

    if args.state.current_game_index < 0
      args.state.current_game_index = GAMES.length - 1
    end

    spacer = 200
    y = 360
    icon_size = 128
    GAMES.each_with_index do |game, i|
      args.outputs.labels << [margin + (spacer * i), y, game::NAME, *BLACK]
      args.outputs.sprites << [margin + (spacer * i), y, icon_size, icon_size, "sprites/icon-#{game}.png"]
    end

    args.outputs.sprites << [margin + (args.state.current_game_index * spacer), y, icon_size, icon_size, "sprites/frame.png"]
  end
end

