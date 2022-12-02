class Home
  INPUT_TICK_DELAY = 8
  MARGIN = 64

  GAMES = [
    FlappyDragon,
    Pong,
    BulletHell,
    Xenotest,
    TheLittleProbe,
  ]

  def initialize
    $gtk.args.audio.each { |k, v| $gtk.args.audio[k] = nil }
    $gtk.stop_music
  end

  def tick(args)
    args.state.ticks_since_last_input ||= 0
    args.state.current_game_index ||= 0
    args.state.fullscreen ||= false
    args.outputs.solids << [0, 0, args.grid.w, args.grid.h, *WHITE]
    args.outputs.labels  << [MARGIN, args.grid.h - MARGIN, 'DragonOS', 5, 0, *BLACK]
    args.outputs.labels  << [MARGIN, 84, 'Select a game to play', 2, 0, *BLACK]

    control_text = "Return home: #{args.inputs.controller_one.connected ? 'SELECT' : 'H' }"
    args.outputs.labels  << [args.grid.w - 80, 50, control_text, -2, 2, *BLACK]
    time = Time.now
    args.outputs.labels  << [args.grid.w - MARGIN, args.grid.h - MARGIN, "#{time.hour}:#{time.min.to_s.rjust(2, '0')}", 2, 1, *BLACK]

    confirm_keys = [:z, :enter, :space]
    if confirm_keys.any? { |k| args.inputs.keyboard.key_down.send(k) } || (args.inputs.controller_one&.key_down&.a)
      play_sound(args.outputs, :confirm)
      args.state.current_game = GAMES[args.state.current_game_index].new
      return
    end

    args.outputs.lines << [ 120, 160, args.grid.w - 120, 160, *BLACK]

    ready_for_input = args.state.ticks_since_last_input > INPUT_TICK_DELAY
    if ready_for_input
      if args.inputs.left
        play_sound(args.outputs, :dir)
        args.state.current_game_index -= 1
        args.state.ticks_since_last_input = 0
      elsif args.inputs.right
        play_sound(args.outputs, :dir)
        args.state.current_game_index += 1
        args.state.ticks_since_last_input = 0
      else
        args.state.ticks_since_last_input += 1
      end
    else
      args.state.ticks_since_last_input += 1
    end

    if args.gtk.platform?(:desktop)
      if args.inputs.keyboard.key_down.f || args.inputs.controller_one&.key_down&.y
        play_sound(args.outputs, :confirm)
        args.state.fullscreen = !args.state.fullscreen
        args.gtk.set_window_fullscreen(args.state.fullscreen)
      end

      fullscreen_text = "Toggle fullscreen: #{args.inputs.controller_one.connected ? 'Y' : 'F' }"
      args.outputs.labels  << [args.grid.w - 80, 84, fullscreen_text, -2, 2, *BLACK]
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
      args.outputs.labels << [MARGIN + (spacer * i), y, game::NAME, *BLACK]
      args.outputs.sprites << [MARGIN + (spacer * i), y, icon_size, icon_size, "sprites/icon-#{game}.png"]
    end

    args.outputs.sprites << [MARGIN + (args.state.current_game_index * spacer), y, icon_size, icon_size, "sprites/frame.png"]
  end

  def play_sound(outputs, key)
    outputs.sounds << "sounds/#{key}.wav"
  end
end
