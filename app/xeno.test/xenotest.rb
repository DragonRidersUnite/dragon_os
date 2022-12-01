class Xenotest < Game
  NAME = "XENO.TEST"

  TRUE_BLACK = { r: 0, g: 0, b: 0 }
  WHITE = { r: 255, g: 255, b: 255 }

  # Access in code with `SPATHS[:my_sprite]`
  SPATHS = {
    cursor: "app/xeno.test/sprites/cursor.png",
    terminal: "app/xeno.test/sprites/terminal.png",
  }

  def debug?
    !$gtk.production
  end

  def label(attrs)
    {
      font: "fonts/Atkinson-Regular.ttf",
    }.merge(WHITE).merge(attrs)
  end

  def play_sound(outputs, key)
    outputs.sounds << "app/xeno.test/sounds/#{key}.wav"
  end

  CONFIRM_KEYS = [:j, :z, :enter, :space]
  def confirm?(inputs)
    inputs.controller_one.key_down&.a ||
      (CONFIRM_KEYS & inputs.keyboard.keys[:down]).any?
  end

  UP_KEYS = [:up, :w]
  def up?(inputs)
    inputs.controller_one.key_down&.up ||
      (UP_KEYS & inputs.keyboard.keys[:down]).any?
  end

  DOWN_KEYS = [:down, :s]
  def down?(inputs)
    inputs.controller_one.key_down&.down||
      (DOWN_KEYS & inputs.keyboard.keys[:down]).any?
  end

  module Scene
    TITLE = :title
    INTRO = :intro
    AUDIT = :audit
    OUTRO = :outro
  end

  def fade_alpha(tick_count)
    60 + (tick_count * 3) % 240
  end

  def tick_title(args)
    labels = []
    labels << label({ x: 120, y: args.grid.h - 120, text: "XENO.TEST", size_enum: 6 })
    labels << label({ x: 120, y: args.grid.h - 180, text: "Prove you're not human", size_enum: 2 })

    controller = args.inputs.controller_one.connected
    if controller
      labels << label({ x: 120, y: 152, text: "Gamepad detected", size_enum: 0 })
    end
    labels << label({ x: 120, y: 120, text: controller ? "Press A to start" : "Press SPACE to start", size_enum: 2 })
      .merge(a: fade_alpha(args.state.tick_count))

    labels << label({ x: args.grid.w - 140, y: 120, text: "A game by Brett Chalupa", size_enum: 0, alignment_enum: 2 })

    if confirm?(args.inputs)
      play_sound(args.outputs, :confirm)
      args.state.scene = Scene::INTRO
      return
    end

    args.outputs.labels << labels
  end

  def render_dialog(args, text)
    args.outputs.labels << label({ x: 120, y: 140, text: text, size_enum: 2 })
    args.outputs.sprites << { x: 1100, y: 120, w: 16, h: 16, path: SPATHS[:cursor], angle: 270, a: fade_alpha(args.state.tick_count) }
  end

  INTRO_TEXT = [
    "> You are walking home.",
    "> An officer approaches. An Enforcer hovers at their side.",
    "OFFICER: Citizen, halt.",
    "OFFICER: We've had reports of humans in the area.",
    "OFFICER: We all know that's unacceptable.",
    "OFFICER: I need you to come with me.",
    "> You know resistance is not an option.",
    "> With no choice, you follow.",
    "...",
    "> You arrive at the station. It's seen better days.",
    "> The officer opens the door to a room.",
    "OFFICER: Step inside.",
    "> The walls are white.",
    "> There are no windows.",
    "> The only thing in the room is a screen with a camera built into it.",
    "OFFICER: Step up to the terminal.",
    "OFFICER: You know the drill. It's a routine test.",
    "OFFICER: You have 20 seconds to prove you're not human.",
  ]
  def tick_intro(args)
    args.state.intro.index ||= 0

    if confirm?(args.inputs)
      play_sound(args.outputs, :confirm)
      args.state.intro.index += 1
    end

    if (args.state.intro.index >= INTRO_TEXT.length)
      args.state.scene = Scene::AUDIT
      return
    end

    render_dialog(args, INTRO_TEXT[args.state.intro.index])
  end

  OUTRO_TEXT = {
    pass: [
      "> The screen shuts off.",
      "> The room is quiet.",
      "> All you hear is the quiet whir of your internals.",
      "> The door opens.",
      "OFFICER: Carry on with your day, citizen.",
      "You walk home.",
      "...",
      "",
      "THE END",
    ],
    fail: [
      "> The screen shuts off.",
      "> The room is quiet.",
      "> All you hear is your heart pounding.",
      "> The door to the room opens.",
      "> You turn around.",
      "OFFICER: I knew from the moment I stopped you.",
      "> The Enforcer approaches, the officer standing behind it.",
      "OFFICER: Die, human scum.",
      "> Before you can take one step, the Enforcer strikes.",
      "> Everything fades to black.",
      "...",
      "..",
      ".",
      "",
      "THE END",
    ]
  }
  def tick_outro(args)
    args.state.pass ||= args.state.audit.score > (args.state.audit.answered_questions.length.to_f * 0.66)
    args.state.outro.index ||= 0

    script = if args.state.pass
             OUTRO_TEXT[:pass]
           else
             OUTRO_TEXT[:fail]
           end

    render_dialog(args, script[args.state.outro.index])

    if confirm?(args.inputs)
      play_sound(args.outputs, :confirm)
      args.state.outro.index += 1
    end

    labels = []
    if (args.state.outro.index == script.length - 1)
      labels << label({ x: 120, y: 600, size_enum: 1, text: "XENO ANSWERS: #{args.state.audit.score}"})
      labels << label({ x: 120, y: 560, size_enum: 1, text: "HUMAN ANSWERS: #{args.state.audit.answered_questions.length - args.state.audit.score}"})
      labels << label({ x: 120, y: 520, size_enum: 1, text: "XENO.TEST SCORE: #{(args.state.audit.score / args.state.audit.answered_questions.length * 100).round}%"})
      labels << label({ x: 120, y: 480, size_enum: 1, text: "MINIMUM PASS THRESHOLD: 66%"})

      if args.state.pass
        labels << label({ x: 120, y: 440, size_enum: 1, text: "NICE JOB YOU ROBOT FREAK"})
      else
        labels << label({ x: 120, y: 440, size_enum: 1, text: "AT LEAST YOUR HUMANITY IS INTACT..."})
      end
    end

    args.outputs.labels << labels

    if (args.state.outro.index >= script.length)
      play_sound(args.outputs, :confirm)
      current_index = args.state.current_game_index
      $gtk.reset
      args.state.current_game_index = current_index
      args.state.current_game = self.class.new
      args.state.intro.index = INTRO_TEXT.length - 1
    end
  end

  def random_index(array)
    rand(array.length)
  end

  QUESTIONS = [
    { q: "Your best friend falls in love with your dog.", a_human: "End the friendship", a_xeno: "Give the dog to them" },
    { q: "You find $20.00 on the ground. You haven't eaten in 7 hours.", a_human: "Take it", a_xeno: "Eat it" },
    { q: "A bird steals your favorite pen.", a_human: "Cry", a_xeno: "Jump up, grab the bird, reclaim the pen" },
    { q: "You spill piping hot coffee on your crotch while driving.", a_human: "Jerk the wheel hard and cause a 10 car pile-up", a_xeno: "Keep driving, unphased" },
    { q: "You're in the desert. A turtle is on its back. It's struggling to turn over.", a_human: "Turn it over", a_xeno: "Keep walking" },
    { q: "A song you hate comes on the radio.", a_human: "Begrudgingly listen to it", a_xeno: "Destroy the radio" },
    { q: "An empty shopping bag blows down the sidewalk.", a_human: "Ignore it", a_xeno: "Pick it up" },
    { q: "Your spouse tells you they're in love with your best friend.", a_human: "Deeply contemplate polygamy", a_xeno: "Explode, literally" },
    { q: "You step on a small plastic block your child constructs castles with.", a_human: "Scream in pain and curse their name", a_xeno: "Walk around with it lodged in your foot all day" },
    { q: "A butterfly lands on your nose.", a_human: "Freak out because ew bugs", a_xeno: "Shed a single tear for making your first friend" },
    { q: "You love this ice cream. It's delicious. The way it melts on your tongue. The sweetness.", a_human: "Eat the entire pint", a_xeno: "Mutter to yourself \"what is an ice cream...\"" },
    { q: "It's your last day on the job. Your boss gifts you a watch and slaps you on the back.", a_human: "Say thank you & put the watch on next to your original watch", a_xeno: "Crush it, you have an internal clock (fools)" },
    { q: "You open your eyes. You're out in nature. The sun hasn't yet risen. Crickets chirp. It's beautiful. What a night.", a_human: "Sigh at the inconvenience of needing to get up and pee", a_xeno: "Freak out because your battery is running low" },
    { q: "Your roommate left 3 chips at the bottom of the bag.", a_human: "Buy a new bag", a_xeno: "Move" },
    { q: "The food brought to your table at the restaurant isn't what you ordered.", a_human: "Eat it because you're impatient and meek", a_xeno: "Shout \"THIS ISN'T THE ORGANIC OIL I ORDERED!\"" },
    { q: "Your new fancy earbud falls out into the toilet.", a_human: "Flush it because that's not going back in my ear", a_xeno: "Grab it but accidentally destroy the toilet bowl" },
  ]
  AUDIT_TITLE_BASE = "Audit in progress"
  def tick_audit(args)
    args.outputs.sprites << { x: 0, y: 0, w: args.grid.w, h: args.grid.h, path: SPATHS[:terminal] }

    state = args.state
    state.audit.count_down ||= 20 * 60
    state.audit.answered_questions ||= []
    state.audit.score ||= 0
    state.audit.title ||= AUDIT_TITLE_BASE + "."
    state.audit.current_question_index ||= rand(QUESTIONS.length)
    state.audit.current_answer_index ||= 0

    labels = []

    if (args.tick_count % 22 == 0)
      state.audit.title = AUDIT_TITLE_BASE + ("." * ((args.tick_count % 3) + 1))
    end

    labels << label({ x: 120, y: 600, size_enum: 3, text: state.audit.title })

    labels << label({ x: 120, y: 560, size_enum: 1, text: "Time remaining: #{state.audit.count_down.idiv(60)}" })

    question = QUESTIONS[state.audit.current_question_index]

    labels << args.string.wrapped_lines(question[:q], 52).map_with_index do |s, i|
      label({ x: 120, y: 400 - (i * 32), text: s, size_enum: 4, alignment_enum: 0 })
    end

    state.audit.current_answers ||= [question[:a_human], question[:a_xeno]].sort_by { rand }

    answer_labels = state.audit.current_answers.map.with_index do |answer, i|
      label({ x: 160, y: 240 - (i * 52), text: answer, size_enum: 2, alignment_enum: 0 })
    end
    labels << answer_labels

    state.audit.count_down -= 1

    if state.audit.count_down % 60 == 0
      play_sound(args.outputs, :tick)
    end

    if state.audit.count_down < 0
      play_sound(args.outputs, :over)
      state.scene = Scene::OUTRO
      return
    end

    if confirm?(args.inputs)
      play_sound(args.outputs, :confirm)
      if state.audit.current_answers[state.audit.current_answer_index] == question[:a_xeno]
        state.audit.score += 1
      end
      state.audit.answered_questions << state.audit.current_question_index
      @i = rand(QUESTIONS.length)
      while state.audit.answered_questions.include?(@i) && state.audit.answered_questions.length < QUESTIONS.length
        @i = rand(QUESTIONS.length)
      end
      state.audit.current_question_index = @i
      state.audit.current_answer_index = 0
      state.audit.current_answers = nil
      return
    end

    if up?(args.inputs)
      play_sound(args.outputs, :dir)
      state.audit.current_answer_index -= 1
      if state.audit.current_answer_index < 0
        state.audit.current_answer_index = state.audit.current_answers.length - 1
      end
    elsif down?(args.inputs)
      play_sound(args.outputs, :dir)
      state.audit.current_answer_index += 1
      if state.audit.current_answer_index > state.audit.current_answers.length - 1
        state.audit.current_answer_index = 0
      end
    end

    active_answer = answer_labels[state.audit.current_answer_index]
    args.outputs.sprites << { x: active_answer[:x] - 32, y: active_answer[:y] - 20, w: 16, h: 16, path: SPATHS[:cursor] }

    args.outputs.labels << labels
  end

  def initialize
    $gtk.args.audio[:bg] = { input: "app/xeno.test/sounds/Night.ogg", looping: true, gain: MUSIC_VOL, pitch: 1.0 }

    if $gtk.cursor_shown?
      $gtk.hide_cursor
    end
  end

  MUSIC_VOL = 1.0

  def tick(args)
    super(args)
    args.outputs.background_color = TRUE_BLACK.values

    args.state.scene ||= Scene::TITLE
    args.state.fullscreen ||= false

    send("tick_#{args.state.scene}", args)

    if args.inputs.mouse.has_focus && args.audio[:bg].paused
      args.audio[:bg].paused = false
    elsif !args.inputs.mouse.has_focus && !args.audio[:bg].paused
      args.audio[:bg].paused = true
    end

    if args.inputs.keyboard.key_down.m
      if args.audio[:bg][:gain] == 0.0
        args.audio[:bg][:gain] = MUSIC_VOL
      else
        args.audio[:bg][:gain] = 0.0
      end
    end

    if args.gtk.platform?(:desktop)
      if args.inputs.keyboard.key_down.f
        args.state.fullscreen = !args.state.fullscreen
        args.gtk.set_window_fullscreen args.state.fullscreen
      end
    end

    debug_tick(args)
  end

  def debug_tick(args)
    return unless debug?

    args.outputs.debug << [args.grid.w - 12, args.grid.h, "#{args.gtk.current_framerate.round}", 0, 1, *WHITE.values].label

    if args.inputs.keyboard.key_down.i
      SPATHS.each { |_, v| args.gtk.reset_sprite(v) }
      args.gtk.notify!("Sprites reloaded")
    end

    if args.inputs.keyboard.key_down.r
      $gtk.reset
    end
  end
end
