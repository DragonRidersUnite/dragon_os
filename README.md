# DragonOS

A showcase of open source games built with [DragonRuby Game Toolkit](https://dragonruby.org/toolkit/game) compiled by the Dragon Rider community.

The aim of this project is to make it easy for someone interested in the engine to boot up all of the game samples and open source games made by the community and play through them.

This project wouldn't be possible without [the DRGTK open source samples](https://github.com/DragonRuby/dragonruby-game-toolkit-contrib/tree/master/samples) and contributions to the community.

## Developing

This repository does not include the engine binary to run it, so you must have a copy of DragonRuby GTK.

1. Download and unzip DragonRuby GTK; known working ver: Nov 12, 2022 - 70cd0b7d234544363972651eca364581f9fe0eb1
2. Move into engine dir and clear out mygame: `rm -rf mygame`
3. Clone the repository into mygame: `git clone git@github.com:DragonRidersUnite/dragon_os.git mygame`
4. Run the `dragonruby` program

## Add Your Game

Are you a Dragon Rider who would like to contribute your open source game to DragonOS? Awesome! Here's what you need to do:

1. Create a folder in the `app` dir for your game, e.g. `app/totris/`
2. Create a main game class, e.g. `app/totris/totris.rb`, that inherits from `Game`, and implements the `tick` method:
    ``` ruby
    class Totris < Game
      def tick(args)
        # your game code here
      end
    end
    ```
3. Put your game's assets in the `totris` directory, e.g. `app/totris/sprites`
4. Add your game's entry class to the `GAMES` constant in `app/home.rb`
5. Add a 64x64 icon to `app/sprites` that follows this name scheme: `icon-Totris.png`, use the class name

It'll now show up in the OS!
