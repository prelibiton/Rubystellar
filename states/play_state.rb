require_relative '../lib/map'
require_relative '../lib/ship'
require_relative '../lib/camera'
require_relative '../lib/laser'
require_relative '../lib/explosion'
require_relative '../lib/asteroid'
require_relative '../lib/level'
require_relative '../lib/numerical'
require_relative '../lib/icon'
require_relative '../lib/enemy'

class PlayState < GameState
  OFFSET = 100

  def initialize
    @music = Gosu::Song.new(
      $window, "media/ObservingTheStar.ogg")
    @music.play
    @map = Map.new
    @ship = Ship.new
    @camera = Camera.new(@ship)
    @level_id = Level.new(@ship)
    @numerical_level = Numerical.new(@level_id.level, OFFSET, 5 * OFFSET + 60)
    

    @icon = Icon.new(OFFSET / 4, OFFSET / 2)
    @numeral_x = Numerical.new(-1, OFFSET / 2 + 20, OFFSET / 2)
    @numerical_lives = Numerical.new(@ship.lives, OFFSET, OFFSET / 2)

    @lasers = []
    @explosions = []
    @asteroids = []
    @enemies = []
  end

  def update
    if rand(@level_id.spawn_rate) < 10
      @asteroids.push( Asteroid.new )
    end

    if rand(1000) < 10
      @enemies.push( Enemy.new(@ship) )
    end

   @asteroids.each do |asteroid|
    if asteroid.x > @ship.x - OFFSET and asteroid.x < @ship.x + OFFSET and
      asteroid.y > @ship.y - OFFSET and asteroid.y < @ship.y + OFFSET
      if @ship.collision?(asteroid)
        @asteroids.delete_at(@asteroids.index(asteroid)) 
        @explosions.push( Explosion.new(@ship.x, @ship.y) )
        @ship.lives -= 1 
      end
    end
  end

  @enemies.each do |enemy|
    if enemy.x > @ship.x - OFFSET and enemy.x < @ship.x + OFFSET and
      enemy.y > @ship.y - OFFSET and enemy.y < @ship.y + OFFSET
      if @ship.collision?(enemy)
        @enemies.delete_at(@enemies.index(enemy)) 
        @explosions.push( Explosion.new(@ship.x, @ship.y) )
        @ship.lives -= 1 
      end
    end
  end

    if @ship.lives == 0
      open('score_log.txt', 'a') do |file|
        file << "SCORE:#{@ship.score} DATE:#{Time.now.strftime("%d/%m/%Y %H:%M")}\n"
      end
      GameState.switch(MenuState.instance)
    end


    @asteroids.each do |asteroid|
      if asteroid.x > @ship.x - 300 and asteroid.x < @ship.x + 300 and
      asteroid.y > @ship.y - 300 and asteroid.y < @ship.y + 300
        @lasers.each do |laser|
          if laser.collision?(asteroid)
            @explosions.push( Explosion.new(asteroid.x, asteroid.y) )
            @asteroids.delete_at(@asteroids.index(asteroid)) 
            @lasers.delete_at(@lasers.index(laser))
            @ship.score += 1
          end
        end
      end
    end

    @enemies.each do |enemy|
      if enemy.x > @ship.x - 300 and enemy.x < @ship.x + 300 and
      enemy.y > @ship.y - 300 and enemy.y < @ship.y + 300
        @lasers.each do |laser|
          if laser.collision?(enemy)
            @explosions.push( Explosion.new(enemy.x,enemy.y) )
            @enemies.delete_at(@enemies.index(enemy)) 
            @lasers.delete_at(@lasers.index(laser))
            @ship.score += 5
          end
        end
      end
    end

    @level = Gosu::Image.from_text(
      $window, "Level", Gosu.default_font_name, 30)
      
    @score = Gosu::Image.from_text(
      $window, "#{@ship.score} ", Gosu.default_font_name, 30)
    
    @ship.update
    @asteroids.map(&:update)
    @asteroids.reject!(&:done?)
    @enemies.map(&:update)
    @enemies.reject!(&:done?)
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
      @enemies.map(&:draw)
    end
  
    @score.draw($window.height + OFFSET, OFFSET / 2, 1)
    @level.draw(OFFSET / 4, 5 * OFFSET + 55, 1)

    @numerical_lives.draw
    @numeral_x.draw
    @numerical_level.draw
    @icon.draw
  end

  def button_down(id)
    @lasers.push(@ship.shoot) if id == Gosu::KbSpace
    $window.close if id == Gosu::KbEscape
  end


end
