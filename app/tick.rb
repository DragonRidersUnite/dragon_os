def tick(args)
  args.outputs.background_color = TRUE_BLACK
  args.state.current_game ||= Home.new
  args.state.current_game.tick(args)
end
