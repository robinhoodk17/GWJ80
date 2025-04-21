extends NPC

var quest_started = false
var quest_finished = false
var approved = false

func handle_dialogue_start(_player_controller) -> void:
	if !quest_started and Globals.current_time < 480.0:
		start_dialogue("chester_quest_start")
		quest_started = true
		return

	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.ROLLERBLADES:
			quest_finished = true
			start_dialogue("chester_give_rollerblades")
			route_manager.speed_scale = 10.0
			current_gamestate = gamestate.HELPED
			Globals.quest_finished("chester", gamestate.HELPED, 1)
			var item : Node3D = _player_controller.grabbing
			item.drop()
			_player_controller.grabbing = null
			item.global_position = Vector3(0,1000,0)
			item.quest_finished = true
			return

	if quest_finished and current_gamestate == gamestate.HELPED and Globals.current_time < 480.0:
		start_dialogue("chester_received_rollerblades")
		return

	if quest_finished and current_gamestate == gamestate.SABOTAGED:
		start_dialogue("chester_shattered_dreams")
		return

	if quest_started and Globals.current_time < 480.0 and !quest_finished:
		start_dialogue("chester_convince")
	
	if Globals.current_time > 480.0:
		if current_gamestate == gamestate.NORMAL:
			start_dialogue("chester_holidays_denied")

		if current_gamestate == gamestate.HELPED:
			start_dialogue("chester_holidays_approved")


func  handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "chester_sabotaged":
		quest_finished = true
		current_gamestate = gamestate.SABOTAGED
		Globals.quest_finished("chester", gamestate.SABOTAGED, -2)
