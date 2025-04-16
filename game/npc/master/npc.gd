extends Node3D
class_name NPC

enum states{IDLE, WALKING, TALKING}
enum gamestate{NORMAL, SABOTAGED, HELPED}
@export_subgroup("Nodes")
@export var animation_player : AnimationPlayer
@export var route_manager : AnimationPlayer
@export var timer : Timer
@export_subgroup("Dialogue and routes")
##the keys are when the event happens, and the values are eventRoute resources with
##the event's data, i.e. the gamestates {NORMAL, SABOTAGED, HELPED} where the NPC
##can move with this route and the route's name
@export var moving_times : Dictionary[float, eventRoute]
##the keys are the timeline's name and the values are the actual timelines, this is just so it's easier to access them
@export var timelines : Dictionary[String, String]
@onready var pop_up: Node3D = $PopUp

var moving_towards : Marker3D = null
var current_state : states = states.IDLE
var current_gamestate : gamestate = gamestate.NORMAL
var current_event : float = 0.0
var original_position : Vector3
var original_rotation : Basis

func _ready() -> void:
	Dialogic.timeline_ended.connect(unpause)
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
			print_debug(current_event, name)
	timer.start(current_event)
	Globals.restart.connect(restart)


func back_to_idle() -> void:
	current_state = states.IDLE
	if animation_player.has_animation("idle"):
		animation_player.play("idle")
	if animation_player.has_animation("Idle"):
		animation_player.play("Idle")


func play(animation_name : String) -> void:
	animation_player.play(animation_name)


func start_walking() -> void:
	if current_event <= 0.0:
		return
	var acceptable_states : Array[gamestate] = moving_times[current_event].acceptable_states
	if current_gamestate in acceptable_states:
		current_state = states.WALKING
		route_manager.play(moving_times[current_event].route)
		print_debug(moving_times[current_event].route)

	if animation_player.has_animation("walk"):
		animation_player.play("walk")
	if animation_player.has_animation("Walk"):
		animation_player.play("Walk")

	var candidate_time : float = 6000
	for i : float in moving_times.keys():
		if i < candidate_time and i > Globals.current_time and i != current_event:
			candidate_time = i
	current_event = candidate_time
	timer.start(current_event)


func restart() -> void:
	animation_player.stop()
	route_manager.stop()
	global_position = original_position
	global_basis = original_rotation
	var expected_time : float = 6000
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
	timer.start(current_event)


func display_prompt() -> void:
	if pop_up:
		if pop_up.visible:
			return
		pop_up.pop_up_show()


func turn_off_prompt() -> void:
	if pop_up:
		pop_up.turn_off_prompt()


func interact(_playermodel, _player_controller) -> void:
	handle_dialogue_start(_player_controller)


func start_dialogue(timeline : String) -> void:
	Dialogic.start(timeline).process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	@warning_ignore("untyped_declaration")
	#Dialogic.timeline_ended.connect(func():get_tree().set('paused', false))
	get_tree().paused = true


func unpause() -> void:
	get_tree().paused = false
	handle_dialogue_end()
	

func handle_dialogue_start(_player_controller : player_controller) -> void:
	###Implemented by sub-classes###
	pass


func  handle_dialogue_end() -> void:
	###Implemented by sub-classes###
	pass
