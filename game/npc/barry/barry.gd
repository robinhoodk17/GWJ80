extends NPC

var first_talk : bool = false
var convinced : bool = false
var quest_started : bool = false
@export var queen : NPC
var quest_progression : int = 6

func handle_dialogue_start(_player_controller) -> void:
	if queen.waiting_plan and !convinced:
		start_dialogue("convince_barry")
		return
	
	if !first_talk:
		start_dialogue("barry_asks_for_help")
		Globals.quest_started("barry", gamestate.HELPED)
		first_talk = true
		quest_started = true
		return
	
	if Globals.current_time < 420.0 and first_talk and current_state != gamestate.HELPED:
		if queen.current_state == gamestate.HELPED:
			start_dialogue("still_need_approval")
		else:
			start_dialogue("barry_waits_for_help")
	
	if Globals.current_time < 420.0 and current_state == gamestate.HELPED:
		start_dialogue("confident_about_motion")
		
	if Globals.current_time > 420.0 and !current_state == gamestate.HELPED:
		start_dialogue("motion_rejected")
	
	if Globals.current_time > 420.0 and current_state == gamestate.HELPED:
		start_dialogue("better_working_conditions")

func quest_progressed() -> void:
	quest_progression -= 1
	if quest_progression == 0:
		Globals.quest_finished("barry", gamestate.HELPED, 3)
		print_debug(Globals.quest_status["barry"])
	else:
		Globals.quest_progress("barry")
		
		
func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "barry_queen_quest_success":
		queen.quest_progressed()
		convinced = true
