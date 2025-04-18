extends NPC

var quest_finished : bool = false
var quest_started : bool = false
@export var barry : NPC

###Override this function to handle dialogue logic###
func handle_dialogue_start(_player_controller) -> void:
	if _player_controller.grabbing != null:
		if _player_controller.grabbing.name == "badge":
			if Globals.current_time > 360.0 and Globals.current_time < 480.0:
				start_dialogue("mama_bear_mee_badge")
				Globals.quest_finished("mee", gamestate.SABOTAGED, -1)
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

	if Globals.quest_status["barry"] == "started":
		start_dialogue("mama_bear_barry_idea")
		return

func  handle_dialogue_end() -> void:
	pass
