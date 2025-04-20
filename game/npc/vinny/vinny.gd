extends NPC


var gave_letter: bool = false
var quest_completed : bool = false
@export var letter : interactable

func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time < 240.0:
		start_dialogue("vinny_and_queen")
		return
	
	if Globals.current_time > 240.0 and Globals.current_time < 300.0:
		start_dialogue("i_love_office_news")
		return

	if Globals.current_time > 300.0 and current_gamestate == gamestate.SABOTAGED:
		start_dialogue("how_could_this_happen")
		return

	if Globals.current_time > 480.0 and !gave_letter:
		start_dialogue("our_love_is_doomed")
		return
		
	if Globals.current_time > 300.0 and Globals.current_time < 480.0:
		if !gave_letter:
			gave_letter = true
			Globals.quest_started("vinny", gamestate.NORMAL)
			letter.global_position = global_position - global_basis.z
			start_dialogue("please_deliver")
			return
		else:
			if quest_completed:
				start_dialogue("butterfly_council")
				return

	if Globals.current_time > 300.0 and Globals.current_time < 480.0 and !quest_completed and gave_letter:
		start_dialogue("its_too_late_romulus_cant_stop_us")
		
	if Globals.current_time > 300.0 and quest_completed:
		start_dialogue("were_running_away")
