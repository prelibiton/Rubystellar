class Ship
  attr_accessor :x, :y, :degrees, :lives, :radius, :size, :score
  RANGE = 300  #fire range
  SPAWN_COORDINATE = 1000

  def initialize
    load_images
    @ship = [@ship_01, @ship_02, @ship_03].shuffle.first
    @x, @y = SPAWN_COORDINATE, SPAWN_COORDINATE
    @degrees = 0     #angle
    @score = 0
    @lives = 4
    @radius = 30
    @size = 1
  end

  def update
    new_x, new_y = @x, @y
    new_x -= speed if $window.button_down?(Gosu::KbA)
    new_x += speed if $window.button_down?(Gosu::KbD)
    new_y -= speed if $window.button_down?(Gosu::KbW)
    new_y += speed if $window.button_down?(Gosu::KbS)
    
    if new_x > 0 and new_x < 2500 and new_y > 0 and new_y < 2500
      @x, @y = new_x, new_y
    else
      @speed = 1.0
    end

    @degrees = change_angle(@degrees,
      Gosu::KbW, Gosu::KbS, Gosu::KbA, Gosu::KbD)
  end

  def draw
    @ship.draw_rot(@x, @y, 1, @degrees)

    case @lives
      when 3
        @damage_01.draw_rot(@x, @y, 1, @degrees)
      when 2
        @damage_02.draw_rot(@x, @y, 1, @degrees)
      when 1
        @damage_03.draw_rot(@x, @y, 1, @degrees)
    end
  end

  def shoot
      case @degrees
        when -45  then Laser.new(@x, @y, @x - 2 * RANGE / 3, @y - 2 * RANGE / 3 , @degrees)
        when 0    then Laser.new(@x, @y, @x, @y - RANGE, @degrees)
        when 45   then Laser.new(@x, @y, @x + 2* RANGE / 3 ,@y - 2 * RANGE / 3, @degrees) 
        when 90   then Laser.new(@x, @y, @x + RANGE, @y, @degrees)
        when 135  then Laser.new(@x, @y, @x + 2 * RANGE / 3, @y + 2 * RANGE / 3, @degrees)   
        when 180  then Laser.new(@x, @y, @x, @y + RANGE, @degrees)
        when 225  then Laser.new(@x, @y, @x - 2 * RANGE / 3, @y + 2 * RANGE / 3, @degrees)   
        when 270  then Laser.new(@x, @y, @x - RANGE, @y, @degrees)
      end
  end

  def collision?(other)
    Gosu::distance(@x, @y, other.x, other.y) < @radius * @size + other.radius * other.size
  end

  def speed
    @speed ||= 1.0
    if moving?
      @speed += 0.03 if @speed < 5
    else
      @speed = 1.0
    end
    @speed
  end

  def change_angle(previous_angle, up, down, right, left)
    if $window.button_down?(up)
      angle = 0.0
      angle += 45.0 if $window.button_down?(left)
      angle -= 45.0 if $window.button_down?(right)
    elsif $window.button_down?(down)
      angle = 180.0
      angle -= 45.0 if $window.button_down?(left)
      angle += 45.0 if $window.button_down?(right)
    elsif $window.button_down?(left)
      angle = 90.0
      angle += 45.0 if $window.button_down?(up)
      angle -= 45.0 if $window.button_down?(down)
    elsif $window.button_down?(right)
      angle = 270.0
      angle -= 45.0 if $window.button_down?(up)
      angle += 45.0 if $window.button_down?(down)
    end
    angle || previous_angle
  end

  private

  def load_images
    @ships = Gosu::TexturePacker.load_json(
      $window, "media/space_ships.json", :precise)
    @ship_01 = @ships.frame('playerShip2_blue.png')
    @ship_02 = @ships.frame('playerShip2_green.png')
    @ship_03 = @ships.frame('playerShip2_orange.png')

    @damage = Gosu::TexturePacker.load_json(
      $window, "media/damage.json", :precise)
    @damage_01 = @damage.frame('playerShip2_damage1.png')
    @damage_02 = @damage.frame('playerShip2_damage2.png')
    @damage_03 = @damage.frame('playerShip2_damage3.png')
  end

  def any_button_down?(*buttons)
    buttons.each do |b|
      return true if $window.button_down?(b)
    end
    false
  end

  def moving?
    any_button_down?(Gosu::KbA, Gosu::KbD, Gosu::KbW, Gosu::KbS)
  end

end