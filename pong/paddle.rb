class Paddle
	include Rubygame::Sprites::Sprite
	attr_accessor :key_down, :key_up, :key_shoot

	def initialize(img)
		@img = img
		@rect = Rubygame::Rect.new
		@rect.size = @img.size
		@rect.x = 0
		@rect.y = 0
		@shoot = false
		@isAI = false
	end

	def set_pos(pos, screen_rect)
		@rect.x = (pos == :left) ? 10 : (screen_rect.w - @rect.w - 10)
		@pos = pos
	end
	
	def stay_in_screen(screen_rect)
		if not screen_rect.contain? @rect then
			@rect.clamp! screen_rect
		end
	end

	def center(rect)
		@rect.y = (rect.h - @rect.h) / 2
	end
	
	def move_speed=(speed)
		@move_speed = speed
	end
	
	def set_keys(up, down, shoot)
		@keys = {
			:up => up,
			:down => down,
			:shoot => shoot
		}
	end

	def update(time, screen_rect, keystate)
		if @isAI
			ai(time, screen_rect)
			stay_in_screen(screen_rect)
		else
			move_vec = bool_to_int(keystate[@keys[:down]]) - bool_to_int(keystate[@keys[:up]])
			@rect.move!(0, move_vec * @move_speed * time)
			stay_in_screen(screen_rect)		
		end		
	end

	def bool_to_int(bool)
		bool ? 1 : 0
	end
		
	def draw on_surface
		@img.blit on_surface, @rect
	end
	
	#AI	
	def set_ai_arguments(ball, paddle)
		@ball = ball
		@paddle = paddle
		@isAI = true
	end
	
	def move_to(dest_y, time)
		dif = dest_y - @rect.cy
		dif = @move_speed * time if dif > @move_speed * time
		dif = -@move_speed * time if dif < -@move_speed * time	
		@rect.move!(0, dif)
	end

	def ai(time, screen_rect)
		if(((@ball.col_rect.cx - col_rect.cx) <=> 0) == (@ball.m_vector[0] <=> 0))
			move_to(screen_rect.cy, time)
		else
			move_to(@ball.col_rect.cy + offset(screen_rect), time)
		end
	end
	
	def offset(screen_rect)
		base = (screen_rect.h + 1) ** (1.0 / (col_rect.h * 0.25))
		delta = @paddle.col_rect.cy - col_rect.cy
		offset = Math.log(delta.abs + 1.0) / Math.log(base)
		offset *= -1 if delta < 0
		return offset
	end
end