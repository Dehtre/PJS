# Ustawienia
@screen_width = 640
@screen_height = 480

# Œcie¿ki i biblioteki
require 'rubygems' rescue puts 'Error'
require 'rubygame'

@root_dir = File.expand_path(File.dirname(__FILE__))
$: << @root_dir
@data_dir = File.join(@root_dir, 'data')
Rubygame::Surface.autoload_dirs << @data_dir

require 'rendering'
require 'menu'
require 'logic'
require 'ball'
require 'paddle'
require 'matrix'

@font_file = File.join(@root_dir, 'data', 'KeiserSousa.ttf')
		
sdl_args = [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
renderer = Renderer.new([@screen_width, @screen_height], sdl_args, @font_file)
renderer.background = 'background.png'

class Game
	def initialize(renderer)
		srand
		@renderer = renderer

		@queue = Rubygame::EventQueue.new
		@queue.enable_new_style_events()

		@clock = Rubygame::Clock.new
		@clock.enable_tick_events
		@clock.target_framerate = 100
    
		@keystate = Hash.new(false)

		@game_state = :menu
		create_menu
		
		# Ustawienia 2
		@win_score = 3
		@ball_speed = 300
		@ball_acceleration = 20
		@paddle_speed = 300
		@right_up_key = :up
		@right_down_key = :down
		@left_up_key = :w
		@left_down_key = :s
	end
 
	def run
		loop {
			@time = @clock.tick.seconds()
			handle_events
			update
			draw
		}
	end
	
	def handle_events
		@queue.each { |event|
			case event
				when Rubygame::Events::QuitRequested then quit
				when Rubygame::Events::KeyPressed
					case event.key
						when :escape then switch_menu
						else @keystate[event.key] = true
					end
				when Rubygame::Events::KeyReleased 
					@keystate[event.key] = false
			end
		}
	end
 
	def update
		case @game_state
			when :game then @logic.update(@time, @keystate)
			when :menu then	@menu.update(@time, @keystate)
		end
	end
 
	def draw
		@renderer.render()
	end

	def switch_menu
		return if @logic.nil?

		if @game_state == :game then
			create_menu
			@game_state = :menu
		elsif @game_state == :menu
			destroy_menu
			@game_state = :game
		end
	end

	def new_game(mode)
		@logic.remove_objects() if not @logic.nil?

		paddle_surface = Rubygame::Surface['paddle.png'].to_display

		ball = Ball.new(Rubygame::Surface['ball.png'].to_display_alpha)
		ball.move_speed = @ball_speed
		ball.acc = @ball_acceleration

		left_paddle = Paddle.new(paddle_surface)
		left_paddle.set_pos(:left, @renderer.screen_rect)
		left_paddle.move_speed = @paddle_speed

		right_paddle = Paddle.new(paddle_surface)
		right_paddle.set_pos(:right, @renderer.screen_rect)
		right_paddle.move_speed = @paddle_speed

		if mode == :singleplayer
			left_paddle.set_ai_arguments(ball, right_paddle)
		else
			left_paddle.set_keys(@left_up_key, @left_down_key, :d)
		end

		right_paddle.set_keys(@right_up_key, @right_down_key, :left)

		score_text = CenteredText.new()
		score_text.pos_y = 25
		score_text.color = [80, 80, 80]

		win_text = CenteredText.new()
		win_text.pos_y = 100
		win_text.color = [0, 0, 0]

		@logic = Logic.new(ball, left_paddle, right_paddle, score_text, win_text, @renderer.screen_rect)
		@logic.win_score = @win_score		
		@logic.add_objects(@renderer)
	end

	def create_menu
		options = Array.new

		options << { :text => 'Kontynuuj', :action => Proc.new { switch_menu } } unless (@logic.nil? or @logic.game_over?)
		options << { :text => 'Jeden gracz', :action => Proc.new { new_game(:singleplayer) and switch_menu } }
		options << { :text => 'Dwoch graczy', :action => Proc.new { new_game(:multiplayer) and switch_menu } }
		options << { :text => 'Wyjscie', :action => Proc.new { quit } }

		@menu = build_menu(options)
		@menu.add_objects(@renderer)
	end
	
	def build_menu(options)
		pos = 100
		step = 60

		options.length.times { |i|
			tmp_text = CenteredText.new()
			tmp_text.text = options[i][:text]
			tmp_text.pos_y = (pos += step)
			tmp_text.color = [0, 0, 0]
			tmp_text.font_type = :normal
			options[i][:text] = tmp_text
		}

		options[0][:text].color = [50, 50, 250]
		options[0][:text].font_type = :selected

		Menu.new(options, 0)
	end
	
	def destroy_menu
		@menu.remove_objects(@renderer)
		@menu = nil
	end
	
	def quit
		Rubygame.quit
		exit
	end
end

class Vector
	def normalize
		self * (1.0 / r)
	end

	def []=(i, v)
		@elements[i] = v
	end
end

newGame = Game.new(renderer)
newGame.run