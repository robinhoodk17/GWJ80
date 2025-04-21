extends NPC

var quest_started : bool = false

func handle_dialogue_start(_player_controller : player_controller) -> void:
	if Globals.current_time < 120:
		start_dialogue("doing_experiment")

	if Globals.current_time > 120 and Globals.current_time < 240:
		if _player_controller.grabbing:
			if _player_controller.grabbing.type == interactable.item_type.CHEESE:
				start_dialogue("found_cheese")
				current_gamestate = gamestate.HELPED
				var item : Node3D = _player_controller.grabbing
				item.drop()
				_player_controller.grabbing = null
				item.global_position = Vector3(0,1000,0)
				return

		start_dialogue("waiting_for_cheese")
