class Renderer
	def initialize(screen_size, sdl_flags, font_file)
		@screen = Rubygame::Screen.new(screen_size, 0, sdl_flags)
		@screen.title = "Pong w Paski v 0.1"
		@screen.show_cursor = false
		@objects = []

		Rubygame::TTF.setup()
		@text_resources = {
			:default => Rubygame::TTF.new(font_file, 30),
			:normal => Rubygame::TTF.new(font_file, 38),
			:selected => Rubygame::TTF.new(font_file, 44)
		}
	end

	def background=(filename)
		surface = Rubygame::Surface[filename].to_display()
		scale = [Rubygame::Screen.get_surface().w.to_f / surface.w, Rubygame::Screen.get_surface().h.to_f / surface.h]	
		@background = surface.rotozoom(0, scale, true)
	end

	def screen_rect
		@screen.make_rect
	end

	def add(o)
		@objects.push(o)
	end

	def remove(o)
		@objects.delete(o)
	end

	def empty()
		@objects.clear()
	end

	def render()
		@background.blit(Rubygame::Screen.get_surface, [0, 0])

		@objects.each { |o|
			if o.kind_of? Text
				o.draw(Rubygame::Screen.get_surface, @text_resources[o.font_type])
			else
				o.draw(Rubygame::Screen.get_surface)
			end
		}
		@screen.flip()    
	end
end

class Text
	attr_accessor :text, :color, :position, :font_type
	
	def initialize()
		@color = [0, 0, 0]
		@position = [0, 0]
		@font_type = :default
	end

	def draw(surface, ttf)
		return if @text.nil? or ttf.nil?
		temp = ttf.render(@text, true, @color)
		temp.blit(surface, @position)
	end
end

class CenteredText < Text
	attr_accessor :pos_y

	def draw(surface, ttf)
		return if @text.nil? or ttf.nil?
		text_size = ttf.size_text(@text)
		@position = [(surface.w - text_size[0]) / 2, @pos_y - text_size[1] / 2]
		super(surface, ttf)
	end
end