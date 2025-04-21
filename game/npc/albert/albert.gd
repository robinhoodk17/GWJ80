extends NPC

func handle_dialogue_start(_player_controller : player_controller) -> void:
	if Globals.current_time < 120:
		start_dialogue("doing_experiment")

	if Globals.current_time > 120 and Globals.current_time < 240:
		if _player_controller.grabbing:
			if _player_controller.grabbing.name == "cheese":
				start_dialogue("found_cheese")
				current_gamestate = gamestate.HELPED
				return

		start_dialogue("waiting_for_cheese")
		


func  handle_dialogue_end() -> void:
	###Implemented by sub-classes###
	pass
