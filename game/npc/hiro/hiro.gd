extends NPC

var quest_started = false
var quest_finished = false
var currently_trapped : bool = false
@export	var safe_timer : Timer
@export var safe_crack_time : float = 480.0

func _ready() -> void:
	safe_timer.timeout.connect(crack_safe)
	safe_timer.start(safe_crack_time)
	Dialogic.timeline_ended.connect(unpause)
	Dialogic.signal_event.connect(handle_dialogue_end)
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
			#print_debug(current_event, name)
	timer.start(current_event)
	Globals.restart.connect(restart)

func crack_safe() -> void:
	currently_trapped = true
	if current_state == gamestate.SABOTAGED:
		make_jail_appear()
		if !quest_finished:
			quest_finished = true
			Globals.quest_finished("hiro", gamestate.SABOTAGED, -1)

func make_jail_appear() -> void:
	pass

func handle_dialogue_start(_player_controller) -> void:
	if _player_controller.grabbing != null:
		if _player_controller.grabbing.type == interactable.item_type.PIGGY:
			start_dialogue("hiro_piggy_bank_attempt")

	if Globals.current_time < 480:
		if !quest_finished:
			start_dialogue("give_wrong_code")
			return
		else:
			start_dialogue("butterfly_council")
			return

	if Globals.current_time > 480:
		if current_state == gamestate.SABOTAGED:
			start_dialogue("hiro_waiting_for_police")
			return
		else:
			start_dialogue("hiro_getting_away")

func restart() -> void:
	currently_trapped = false
	safe_timer.start(safe_crack_time)
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

func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "hiro_sabotaged":
		current_gamestate = gamestate.SABOTAGED
		Globals.quest_progress("hiro")
