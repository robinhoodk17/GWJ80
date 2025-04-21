extends NPC

@export var vinny : NPC
@export var queen : NPC
@export var albert : NPC
var quest_finished : bool = false

func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time < 300.0:
		if _player_controller.grabbing == null:
			start_dialogue("romulus_my_sons_college")
			return
		else:
			if _player_controller.grabbing.type != interactable.item_type.LETTER:
				start_dialogue("romulus_my_sons_college")
				return
	
	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.LETTER:
			if Globals.current_time < 240.0: 
				if (vinny.current_gamestate == gamestate.NORMAL or vinny.current_gamestate == gamestate.SABOTAGED):
					start_dialogue("romulus_will_publish_this_to_become_ceo")
					var item : Node3D = _player_controller.grabbing
					item.drop()
					item.quest_finished = true
					_player_controller.grabbing = null
					item.global_position = Vector3(0,1000,0)
					vinny.current_gamestate = gamestate.SABOTAGED
					queen.current_gamestate = gamestate.SABOTAGED
					Globals.quest_finished("vinny", gamestate.SABOTAGED, -2)
					return
				else:
					start_dialogue("butterfly_council")
					return
			else:
				start_dialogue("romulus_too_late_to_use_this")
				return
	
	if Globals.current_time > 480.0:
		if _player_controller.grabbing == null:
			start_dialogue("romulus_hope_piggy_is_ok")
			return
		else:
			if _player_controller.grabbing.type == interactable.item_type.CHEESE:
				start_dialogue("romulus_albert_quest")
				var item : Node3D = _player_controller.grabbing
				item.drop()
				_player_controller.grabbing = null
				item.global_position = Vector3(0,1000,0)
				return
			
	
	if Globals.current_time > 300.0 and Globals.current_time < 480.0:
		start_dialogue("romulus_too_busy_to_talk")
		return

func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "albert_helped":
		albert.quest_completed = true
		albert.current_gamestate = gamestate.HELPED
		Globals.quest_finished("albert", gamestate.HELPED, 2)
	if signal_argument == "albert_sabotaged":
		albert.quest_completed = true
		Globals.quest_finished("albert", gamestate.SABOTAGED, -2)
		albert.current_gamestate = gamestate.SABOTAGED
