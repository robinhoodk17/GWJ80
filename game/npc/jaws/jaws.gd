extends NPC

func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time < 255.0:
		start_dialogue("jaws_in_room")

	if Globals.current_time > 255.0 and Globals.current_time < 300.0:
		start_dialogue("jaws_watches_news")

	if Globals.current_time > 300.0 and Globals.current_time < 480.0:
		start_dialogue("jaws_outside_room")
	
	if Globals.current_time > 480.0 and gamestate.SABOTAGED:
		start_dialogue("jaws_realizes_sabotage")

	if Globals.current_time > 480.0 and gamestate.NORMAL:
		start_dialogue("jaws_files_safe")
