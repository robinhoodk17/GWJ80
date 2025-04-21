extends NPC

@export var ollie : NPC
@export var hiro : NPC
@export var queen : NPC
var convinced : bool = false
var quest_finished : bool = false
var convinced_first_time : bool = false
var first_run : bool = true

func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time > 360.0 and queen.waiting_plan and !convinced:
		start_dialogue("ollie_queen_bee")
		return

	if hiro.current_gamestate == gamestate.SABOTAGED and ! hiro.quest_finished:
		start_dialogue("ollie_traveller_caught_thief")
		hiro.quest_finished = true
		Globals.quest_finished("hiro", gamestate.SABOTAGED, 1)
		return

	if Globals.current_time < 240.0:
		start_dialogue("ollie_traveller_drinking_coffee")
		return

	if Globals.current_time > 240.0 and Globals.current_time < 485.0:
		start_dialogue("ollie_traveller__avoids_himself")
		return
	
	if Globals.current_time > 485.0:
		start_dialogue("ollie_traveller_paradox")
	return
