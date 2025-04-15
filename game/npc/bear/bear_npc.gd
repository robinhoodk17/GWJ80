extends NPC


###Override this function to handle dialogue logic###
func handle_dialogue_start(_player_controller) -> void:
	if _player_controller.grabbing != null:
		start_dialogue("cube")
	else :
		start_dialogue("no_cube")

###Override this function to handle what happens after the dialogue ###
func  handle_dialogue_end() -> void:
	pass
