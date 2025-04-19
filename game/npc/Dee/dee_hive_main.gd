extends NPC

@export var barry : NPC
@export var timer_for_present : Timer
@export var time_of_present : float = 430.0
var convinced_barry_quest : bool = false
var quest_finished : bool = false
var gave_present = false

func _ready() -> void:
	Dialogic.timeline_ended.connect(unpause)
	Dialogic.signal_event.connect(handle_dialogue_end)
	timer_for_present.timeout.connect(fix_decision)
	original_position = global_position
	original_rotation = global_basis
	timer.timeout.connect(start_walking)
	var expected_time : float = 6000
	if animation_player.has_animation("idle"):
		animation_player.play("idle")
	if animation_player.has_animation("Idle"):
		animation_player.play("Idle")
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
	timer.start(current_event)
	Globals.restart.connect(restart)

func handle_dialogue_start(_player_controller) -> void:
	if barry.quest_started and !convinced_barry_quest:
		start_dialogue("dee_barry_quest")
		return

	if Globals.current_time < 300.0:
		if quest_finished:
			start_dialogue("butterfly_council")
			return
		match current_gamestate:
			gamestate.NORMAL:
				start_dialogue("dee_skates_or_briefcase")
				return
			gamestate.HELPED:
				start_dialogue("dee_skates")
				return
			gamestate.SABOTAGED:
				start_dialogue("dee_briefcase")
				return

	if Globals.current_time > 420 and Globals.current_time < 430:
		start_dialogue("dee_already_got_present")
		return
	
	if Globals.current_time > 430:
		match current_gamestate:
			gamestate.NORMAL:
				start_dialogue("dee_undecisive")
				return
			gamestate.HELPED:
				start_dialogue("dee_good_present")
				return
			gamestate.SABOTAGED:
				start_dialogue("dee_bad_present")
				return

func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "dee_union":
		convinced_barry_quest = true
		barry.quest_progressed()
	
	if signal_argument == "dee_briefcase":
		current_gamestate = gamestate.SABOTAGED
	
	if signal_argument == "dee_skates":
		current_gamestate = gamestate.HELPED

func fix_decision() -> void:
	if !quest_finished and current_gamestate != gamestate.NORMAL:
		quest_finished = true
		if current_gamestate == gamestate.HELPED:
			Globals.quest_finished("dee", current_gamestate, 1)
		if current_gamestate == gamestate.SABOTAGED:
			Globals.quest_finished("dee", current_gamestate, -1)

func restart() -> void:
	gave_present = false
	animation_player.stop()
	route_manager.stop()
	route_manager.stop()
	timer_for_present.stop()
	timer_for_present.start(time_of_present)
	global_position = original_position
	global_basis = original_rotation
	var expected_time : float = 6000
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
	timer.start(current_event)
