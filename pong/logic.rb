class Logic
	attr_writer :screen_rect, :win_score

	def initialize(ball, left_paddle, right_paddle, score_text, win_text, screen_rect)
		@screen_rect = screen_rect
		@ball = ball
		@left_paddle = left_paddle
		@right_paddle = right_paddle

		@score_text = score_text
		@win_text = win_text
		
		@left_player_score = 0
		@right_player_score = 0

		set_score_text
		new_round
	end

	def add_objects(renderer)
		renderer.add(@ball)
		renderer.add(@left_paddle)
		renderer.add(@right_paddle)
		renderer.add(@score_text)
		renderer.add(@win_text)
		@renderer = renderer
	end

	def remove_objects()
		@renderer.remove(@ball)
		@renderer.remove(@left_paddle)
		@renderer.remove(@right_paddle)
		@renderer.remove(@score_text)
		@renderer.remove(@win_text)
		@renderer = nil
	end

	def update(time, keystate)
		@timer += time
		update_paddles(time, keystate)
		update_ball(time)
	end

	def update_paddles(time, keystate)
		@left_paddle.update(time, @screen_rect, keystate)
		@right_paddle.update(time, @screen_rect, keystate)
	end

	def update_ball(time)
		@ball.update(time) unless @mode == :sleep

		case @mode
			when :normal
				case @ball.check_against_screen(@screen_rect)
					when :out_left then score :right
					when :out_right then score :left
				end
			when :scored then new_round if @timer >= 1
			when :sleep
				if @timer >= 1
					@timer = 0
					@mode = :normal
				end
		end

		if @timer > 0.1 && (@ball.handle_collision(@left_paddle) || @ball.handle_collision(@right_paddle))
			@ball.speed_up
			@timer = 0
		end
	end
	
	def set_score_text
		@score_text.text = "#{@left_player_score} - #{@right_player_score}"
	end

	def score(player)
		@left_player_score += 1 if player == :left
		@right_player_score += 1 if player == :right

		set_score_text
		
		@mode = :scored
		@timer = 0

		if(@left_player_score >= @win_score ||
			@right_player_score >= @win_score)
			game_over
		end
	end

	def new_round
		@mode = :sleep
		@timer = 0

		@ball.center(@screen_rect)
		@ball.m_vector = Vector[(rand + 0.5) * (@right_player_score >= @left_player_score ? 1 : -1), rand - 0.5].normalize
		@ball.reset_speed

		@left_paddle.center(@screen_rect)
		@right_paddle.center(@screen_rect)
	end

	def game_over
		@mode = :game_over
		@win_text.text = "Gracz #{ @left_player_score > @right_player_score ? 2 : 1 } wygrywa!"
	end

	def game_over?
		@mode == :game_over
	end
end