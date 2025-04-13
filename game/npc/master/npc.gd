extends Node3D
class_name NPC

enum states{IDLE, WALKING, TALKING}
enum gamestate{NORMAL, SABOTAGED, HELPED}
@export var current_location : Marker3D
@export var animation_player : AnimationPlayer
@export var route_manager : AnimationPlayer
@export var timer : Timer
@export var speed : float = 5.0
##stores the position to move to and the times (in seconds) when it happens
@export var moving_times : Dictionary[float, Marker3D]
##stores where should it move to, depending on the npc state
@export var moving_locations : Dictionary[Marker3D, gamestate]
@export var timelines : Dictionary[Marker3D, String]
##stores which animation to use to move somewhere
@export var routes : Dictionary[Marker3D, String]
@onready var pop_up: Node3D = $PopUp

var moving_towards : Marker3D = null
var current_state : states = states.IDLE
var current_gamestate : gamestate = gamestate.NORMAL
var current_event : float = 0.0
var original_position : Vector3
var original_rotation : Basis

func _ready() -> void:
	original_position = global_position
	original_rotation = global_basis
	timer.timeout.connect(start_walking)
	var expected_time : float = 6000
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
	timer.start(current_event)
	Globals.restart.connect(restart)


func back_to_idle() -> void:
	current_location = moving_towards
	current_state = states.IDLE
	animation_player.play("idle")


func start_walking() -> void:
	var possible_move : Marker3D = moving_times[current_event]
	if moving_locations[possible_move] == current_gamestate:
		moving_towards = possible_move
		current_state = states.WALKING
		animation_player.play("walk")
		route_manager.play(routes[moving_towards])

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


func turn_off_prompt():
	if pop_up:
		pop_up.turn_off_prompt()


func interact():
	Dialogic.start(timelines[current_location]).process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.timeline_ended.connect(func():get_tree().set('paused', false))
	get_tree().paused = true
	pass
