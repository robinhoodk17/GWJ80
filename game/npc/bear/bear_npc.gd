extends NPC

var already_talked = false

###Override this function to handle dialogue logic###
func handle_dialogue_start(_player_controller) -> void:
	if already_talked:
		start_dialogue("second_talk")
	else :
		start_dialogue("first_talk")

###Override this function to handle what happens after the dialogue ###
func  handle_dialogue_end() -> void:
	current_gamestate = gamestate.SABOTAGED
