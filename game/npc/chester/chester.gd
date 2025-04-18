extends NPC

var quest_started = false
var quest_finished = false
var approved = false

###Override this function to handle dialogue logic###
func handle_dialogue_start(_player_controller) -> void:
	if !quest_finished:
		if !quest_started:
			Globals.quest_started("chester", gamestate.HELPED)
			quest_started = true
		start_dialogue("chester_quest_start")
		return

	if quest_finished:
		start_dialogue("chester_give_rollerblades")
	elif quest_finished: 
		start_dialogue("chester_received_rollerblades")
	elif quest_finished and Globals.current_time > 480.0 and Globals.current_time < 600.0:
		start_dialogue("chester_holidays_approved")
		approved = true
	elif quest_finished: 
		start_dialogue("chester_holidays_denied")
	elif quest_finished: 
		start_dialogue("chester_convince")

	else:
		start_dialogue("chester_shattered_dreams")
		

###Override this function to handle what happens after the dialogue ###
func  handle_dialogue_end() -> void:
	current_gamestate = gamestate.SABOTAGED
