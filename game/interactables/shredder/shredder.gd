extends NPC


func handle_dialogue_start(_player_controller) -> void:
	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.MAIL:
			start_dialogue("you_destroyed_this_mail")
			var item : Node3D = _player_controller.grabbing
			item.drop()
			item.quest_finished = true
			_player_controller.grabbing = null
			item.global_position = Vector3(0,1000,0)
			Globals.quest_finished("dovey", gamestate.SABOTAGED, -1)
			return

		if _player_controller.grabbing.type == interactable.item_type.FILES:
			start_dialogue("you_destroyed_this_mail")
			var item : Node3D = _player_controller.grabbing
			item.drop()
			item.quest_finished = true
			_player_controller.grabbing = null
			item.global_position = Vector3(0,1000,0)
			Globals.quest_finished("dovey", gamestate.SABOTAGED, -1)
			return
		
		start_dialogue("you_cant_shred_this")
		return
	start_dialogue("this_is_a_paper_shredder")
