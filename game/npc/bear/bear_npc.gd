extends NPC

var quest_finished : bool = false
var quest_started : bool = false
var convinced_barry_quest : bool = false
@export var barry : NPC

###Override this function to handle dialogue logic###
func handle_dialogue_start(_player_controller) -> void:
	if barry.quest_started and !convinced_barry_quest:
		start_dialogue("mama_bear_barry_idea")
		return

	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.BADGE:
			if Globals.current_time > 360.0 and Globals.current_time < 480.0:
				start_dialogue("mama_bear_mee_badge")
				Globals.quest_finished("mee", gamestate.SABOTAGED, -1)
				var item : Node3D = _player_controller.grabbing
				item.drop()
				item.quest_finished = true
				_player_controller.grabbing = null
				item.global_position = Vector3(0,1000,0)
				return

			if Globals.current_time < 360.0:
				start_dialogue("mama_bear_too_early")
				return
			
			if Globals.current_time > 480.0:
				start_dialogue("mama_bear_no_overtime")
				return

	if !quest_finished:
		if !quest_started:
			Globals.quest_started("mama_bear", gamestate.HELPED)
			quest_started = true
		start_dialogue("mama_bear_decision_tree")
		return

	if quest_finished:
		start_dialogue("mama_bear_correct_choices")
		return



func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "mama_bear_barry_quest":
		convinced_barry_quest = true
		barry.quest_progressed()
		
	
	if signal_argument == "mama_bear_quest_finished":
		Globals.quest_finished("mama_bear", gamestate.HELPED, 1)
		quest_finished = true
