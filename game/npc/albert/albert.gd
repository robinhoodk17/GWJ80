extends NPC

var quest_started : bool = false
var room_meeting_occurred : bool = false
var ollie : NPC
var	quest_completed : bool = true

func handle_dialogue_start(_player_controller : player_controller) -> void:
	if Globals.current_time > 590 and ollie.quest_finished:
		start_dialogue("albert_helped_ollie")
	
	if Globals.current_time < 120:
		start_dialogue("albert_waiting_experiment")
		return

	if Globals.current_time > 120 and Globals.current_time < 240:
		if _player_controller.grabbing:
			if _player_controller.grabbing.type == interactable.item_type.CHEESE:
				start_dialogue("albert_delivered_cheese")
				quest_started = true
				Globals.quest_started("albert", gamestate.HELPED)
				var item : Node3D = _player_controller.grabbing
				item.drop()
				_player_controller.grabbing = null
				item.global_position = Vector3(0,1000,0)
				return

		start_dialogue("waiting_for_cheese")
		return

	if Globals.current_time > 240.0:
		if _player_controller.grabbing:
			if _player_controller.grabbing.type == interactable.item_type.CHEESE:
				start_dialogue("albert_delivered_cheese_late")
				return
		if !quest_started:
			start_dialogue("albert_failed_experiment")
			return

	if Globals.current_time > 300.0 and Globals.current_time < 420.0:
		if quest_started:
			start_dialogue("albert_room_meeting")
			Globals.quest_progress("albert")
			room_meeting_occurred = true
			return
	
	if Globals.current_time > 420.0:
		if room_meeting_occurred:
			start_dialogue("albert_waiting_for_quest")
			return
		else:
			start_dialogue("albert_was_late_to_meeting")
			return
