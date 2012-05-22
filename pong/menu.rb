class Menu
	def initialize(options, selection)
		@options = options
		@selection = selection
		@last_keystate = Hash.new { false }
	end

	def add_objects(renderer)
		@options.each { |o| renderer.add(o[:text]) }
	end

	def remove_objects(renderer)
		@options.each { |o| renderer.remove(o[:text]) }
	end

	def update(time, keystate)
		old_selection = @selection

		@selection += 1 if key_typed(keystate, :down)
		@selection -= 1 if key_typed(keystate, :up)

		@selection = @options.size - 1 if @selection < 0
		@selection = 0 if @selection == @options.size()

		@options[@selection][:action].call if key_typed(keystate, :return)

		@last_keystate = keystate.clone

		if(old_selection != @selection)
			swap(old_selection, @selection)
			return :selection_changed
		end
	end
	
	def key_typed(keystate, key)
		keystate[key] && !@last_keystate[key]
	end

	def swap(old, new)
		old_selection = @options[old][:text]
		new_selection = @options[new][:text]

		tmp_color = old_selection.color
		old_selection.color = new_selection.color
		new_selection.color = tmp_color

		tmp_type = old_selection.font_type
		old_selection.font_type = new_selection.font_type
		new_selection.font_type = tmp_type
	end
end