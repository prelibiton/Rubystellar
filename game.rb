require 'gosu'

require_relative 'lib/player'
require_relative 'lib/laser'


module Engine
  class GameWindow < Gosu::Window
    def initialize
      super(720, 480, false)

      self.caption = "Interstellar"
      @music = Gosu::Song.new(self, "sounds/Uncertain-Future.ogg")
      @music.volume = 0.4
      @music.play(true)
      @background_image = Gosu::Image.new(self, "images/space2.png", true)

      @player = Player.new(self)
      @player.position(310, 420)


      @planet = Gosu::Image.new(self,"images/p3shaded.png", true)
      @font = Gosu::Font.new(self, Gosu::default_font_name, 20)

    end

    def update
      @player.move(-@player.speed) if button_down? Gosu::KbLeft
      @player.move(@player.speed)  if button_down? Gosu::KbRight 
      @player.shoot                if button_down? Gosu::KbSpace
    end

    def draw  
      @background_image.draw(0, 0, 0)
      @planet.draw_rot(150,100,1,1)
      @player.draw
      @font.draw("Score: #{@player.score}", 10, 10, 1, 1.0, 1.0, 0xffffff00)
      @font.draw("Level: ", 10, 30, 1, 1.0, 1.0, 0xffffff00)
    end

    def button_down(id)
      close if id == Gosu::KbEscape
      
      if id == Gosu::KbM 
       if @music.playing?
          @music.pause 
        else
          @music.play
        end
      end
      
    end

  end
end

Engine::GameWindow.new.show