class Ball
	include Rubygame::Sprites::Sprite
	attr_accessor :m_vector, :m_speed, :acc
	
	def initialize(img)
		@img = img
		@rect = Rubygame::Rect.new
		@rect.size = @img.size
		@rect.topleft = [0, 0]
		@m_vector = Vector[0, 0]
		@m_speed = 0
	end

	def move_speed=(speed)
		@init_speed = @m_speed = speed
	end

	def center(rect)
		@rect.topleft = [(rect.w - @rect.w) / 2, (rect.h - @rect.h) / 2]
	end
	
	def update(time)
		@rect.move!(*(@m_vector * (@m_speed * time)))
	end

	def check_against_screen(screen_rect)
		return if screen_rect.contain?(@rect)

		if(@rect.y < screen_rect.y)
			@rect.y = mirror(@rect.y, screen_rect.y)
			@m_vector[1] *= -1
			return :bump
		elsif(@rect.y > screen_rect.y + screen_rect.h - @rect.h)
			@rect.y = mirror(@rect.y, screen_rect.y + screen_rect.h - @rect.h)
			@m_vector[1] *= -1
			return :bump
		else
			return @rect.x < screen_rect.x ? :out_left : :out_right
		end
	end

	def mirror(pos, axis)
		2 * axis - pos
	end

	def handle_collision(paddle)
		if @rect.collide_rect?(paddle.col_rect)
			@m_vector = Vector[(@rect.cx - paddle.col_rect.cx) * 2, @rect.cy - paddle.col_rect.cy].normalize
			true
		else
			false
		end
	end
	
	def draw on_surface
		@img.blit on_surface, @rect
	end

	def speed_up
		@m_speed += @acc
	end

	def reset_speed
		@m_speed = @init_speed
	end
end