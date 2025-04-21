extends NPC

var waiting_plan : bool = false
var quest_progression = 2
var convinced_barry_quest : bool = false
var letter_delivered : bool = false
var quest_completed : bool = false
@export var vinny : NPC
@export var barry : NPC

func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time > 300.0 and Globals.current_time < 360.0:
		start_dialogue("i_love_office_news_queen_bee")
		return

	if Globals.current_time > 360.0:
		if current_gamestate == gamestate.SABOTAGED:
			start_dialogue("how_could_this_happen_queen_bee")
			return

	if barry.first_talk and !convinced_barry_quest:
		start_dialogue("convince_queen")
	
	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.LETTER:
			if Globals.quest_status["vinny"] == gamestate.NORMAL:
				Globals.quest_started("vinny", gamestate.HELPED)
				var item : Node3D = _player_controller.grabbing
				item.drop()
				_player_controller.grabbing = null
				item.global_position = Vector3(0,1000,0)
				letter_delivered = true
				start_dialogue("queen_bee_plan")
				waiting_plan = true
			else:
				start_dialogue("butterfly_council")
	
	if waiting_plan and Globals.current_time > 360.0 and Globals.current_time < 480.0:
		start_dialogue("waiting_for_the_plan")
	
	if waiting_plan and Globals.current_time > 480.0:
		start_dialogue("too_late_for_the_plan")
		
	if Globals.current_time > 360.0 and current_gamestate == gamestate.HELPED and quest_completed and Globals.current_time < 480.0:
		start_dialogue("waiting_to_run_away")

	if Globals.current_time > 480.0 and current_gamestate == gamestate.HELPED and quest_completed:
		start_dialogue("were_running_away")

func quest_progressed() -> void:
	quest_progression -= 1
	if quest_progression == 0:
		vinny.current_gamestate = gamestate.HELPED
		current_gamestate == gamestate.HELPED
		Globals.quest_finished("vinny", gamestate.HELPED, 2)
	else:
		Globals.quest_progress("vinny")

func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "queen_barry_quest":
		convinced_barry_quest = true
		barry.quest_progressed()
