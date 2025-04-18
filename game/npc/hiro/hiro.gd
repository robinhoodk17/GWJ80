extends NPC

var quest_started = false
var quest_finished = false

###Override this function to handle dialogue logic###
func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time > 480 and Globals.current_time < 600 and !quest_finished:
		if !quest_started:
			Globals.quest_started("hiro", gamestate.HELPED)
			quest_started = true
		start_dialogue("piggy_bank_attempt")
		return

	if quest_finished:
		start_dialogue("give_wrong_code")
	else :
		start_dialogue("waiting_for_police")
		

###Override this function to handle what happens after the dialogue ###
func  handle_dialogue_end() -> void:
	current_gamestate = gamestate.SABOTAGED
