# DragonOS

![Iconographic red dragon with the word 'DragonOS' beneath](https://user-images.githubusercontent.com/928367/204061027-b46c0172-b6a0-4fc7-94ab-137bbdd67649.png)

![Screenshot of home screen showing Flappy Dragon, Pong, and Bullet Hell as the selectable games](https://user-images.githubusercontent.com/928367/204060969-e2cdd572-9694-43a2-8a60-8d1c46f10acd.png)

[Play the games on Itch.](https://dragonridersunite.itch.io/dragon-os)

A showcase of open source games built with [DragonRuby Game Toolkit](https://dragonruby.org/toolkit/game) compiled by the Dragon Rider community.

The aim of this project is to make it easy for someone interested in the engine to boot up all of the game samples and open source games made by the community and play through them.

This project wouldn't be possible without [the DRGTK open source samples](https://github.com/DragonRuby/dragonruby-game-toolkit-contrib/tree/master/samples) and contributions from the community.

## Developing

This repository does not include the engine binary to run it, so you must have a copy of DragonRuby GTK.

1. Download and unzip DragonRuby GTK; known working ver: v3.24
2. Move into engine dir and clear out mygame: `rm -rf mygame`
3. Clone the repository into mygame: `git clone git@github.com:DragonRidersUnite/dragon_os.git mygame`
4. Run the `dragonruby` program

## Release Steps

1. update changelog
2. bump ver in metadata/game_metadata.txt & commit
3. tag with git, e.g. `git tag -a v0.3.0`
4. push tag to GitHub with `git push origin --tags`
5. build the game with `dragonruby-publish --only-package mygame`
6. upload the builds to itch
7. publish itch update

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
5. Add a 128x128 icon to `app/sprites` that follows this name scheme: `icon-Totris.png`, use the class name

It'll now show up in the OS!
