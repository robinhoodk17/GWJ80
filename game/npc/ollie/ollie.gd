extends NPC

@export var albert : NPC
@export var ollie_traveller : NPC
@export var queen : NPC
var convinced : bool = false
var quest_finished : bool = false
var convinced_first_time : bool = false
var first_run : bool = true

func handle_dialogue_start(_player_controller) -> void:
	if Globals.current_time > 360.0 and queen.waiting_plan and !convinced:
		start_dialogue("ollie_queen_bee")
		return

	if Globals.current_time < 360.0:
		start_dialogue("ollie_snoring")
		Globals.quest_started("ollie", gamestate.HELPED)
		return
	
	if Globals.current_time > 360.0 and first_run and !convinced_first_time:
		if albert.room_meeting_occurred:
			start_dialogue("ollie_regrets_variant")
			convinced_first_time = true
			current_gamestate = gamestate.HELPED
			ollie_traveller.current_gamestate = gamestate.HELPED
			return
		else:
			start_dialogue("ollie_regrets")
			return
	
	if Globals.current_time > 485.0:
		if quest_finished:
			start_dialogue("ollie_brave")
			return
		if convinced_first_time and first_run:
			start_dialogue("ollie_going_to_albert")
			return
		if !first_run :
			if Globals.current_time < 550.0:
				start_dialogue("ollie_paradox")
				return
			else:
				start_dialogue("ollie_too_late")
				return

func restart() -> void:
	if !quest_finished:
		current_gamestate = gamestate.NORMAL
	if convinced_first_time:
		first_run = false
	animation_player.stop()
	route_manager.stop()
	route_manager.stop()
	global_position = original_position
	global_basis = original_rotation
	var expected_time : float = 6000
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
	timer.start(current_event)

func  handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "ollie_convince_travel":
		Globals.quest_finished("ollie", gamestate.HELPED, 2)
		current_gamestate = gamestate.HELPED
		quest_finished = true
	if signal_argument == "ollie_convinced_signal":
		queen.quest_progressed()
		convinced = true
		ollie_traveller.convinced = true
