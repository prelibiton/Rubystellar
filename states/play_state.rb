require_relative '../lib/map'
require_relative '../lib/ship'
require_relative '../lib/camera'
require_relative '../lib/laser'
require_relative '../lib/explosion'
require_relative '../lib/asteroid'
require_relative '../lib/level'
require_relative '../lib/numerical'

class PlayState < GameState

  def initialize
    @music = Gosu::Song.new(
      $window, "media/ObservingTheStar.ogg")
    @music.play
    @map = Map.new
    @ship = Ship.new(@map)
    @camera = Camera.new(@ship)
    @level_id = Level.new(@ship)
    @numerical_lives = Numerical.new(@ship.lives, 100, 565)
    @numeral_x = Numerical.new(-1, 80, 565)
    @numerical_level = Numerical.new(@level_id.level, 100, 535)
    @numeral_X = Numerical.new(-1, 80, 535)
    @lasers = []
    @explosions = []
    @asteroids = []
  end

  def update
    if rand(@level_id.spawn_rate) < 10
      @asteroids.push( Asteroid.new )
    end
    @asteroids.map(&:update)
    @asteroids.reject!(&:done?)

   @asteroids.each do |asteroid| 
    if @ship.collision?(asteroid)
      @asteroids.delete_at(@asteroids.index(asteroid)) 
      @explosions.push(Explosion.new(@ship.x,@ship.y))
      @ship.lives -= 1 
    end
  end

    if @ship.lives == 0 
      GameState.switch(MenuState.instance)
    end

   @lives = Gosu::Image.from_text(
      $window, "LIVE#{'S' if @ship.lives != 1}",
       Gosu.default_font_name, 30)

   @level = Gosu::Image.from_text(
      $window, "LEVEL", Gosu.default_font_name, 30)

    @ship.update(@camera)

    @asteroids.each do |asteroid| 
      @lasers.each do |laser|
        if laser.collision?(asteroid)
          @explosions.push(Explosion.new(asteroid.x,asteroid.y))
          @asteroids.delete_at(@asteroids.index(asteroid)) 
          @lasers.delete_at(@lasers.index(laser))
          @ship.score += 1
        end
      end
    end
      
    @score = Gosu::Image.from_text(
      $window, "SCORE:#{@ship.score} ", Gosu.default_font_name, 30)
   
    @lasers.map(&:update) 
    @lasers.reject!(&:done?)
    @explosions.map(&:update)
    @explosions.reject!(&:done?)
    @level_id.update
    @camera.update
    @numerical_lives.update(@ship.lives)
    @numerical_level.update(@level_id.level)
    $window.caption = 
      "[FPS: #{Gosu.fps}. Ship @ #{@ship.x.round}:#{@ship.y.round}]"
  end

  def draw
    off_x =  $window.width / 2 - @camera.x
    off_y =  $window.height / 2 - @camera.y

    $window.translate(off_x, off_y) do
      @map.draw(@camera)
      @ship.draw
      @explosions.map(&:draw)
      @lasers.map(&:draw)
      @asteroids.map(&:draw)
    end
    
    @score.draw(1, 500, 1)
    @level.draw(1, 530, 1)
    @lives.draw(1, 560, 1)
    @numerical_lives.draw
    @numeral_x.draw
    @numerical_level.draw
    @numeral_X.draw
  end

  def button_down(id)
    @lasers.push(@ship.shoot) if id == Gosu::KbSpace
    $window.close if id == Gosu::KbEscape
  end


end