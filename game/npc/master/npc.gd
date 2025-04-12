extends StairsCharacter3D

enum states{IDLE, WALKING, TALKING}
enum gamestate{NORMAL, SABOTAGED, HELPED}
@export var animation_player : AnimationPlayer
@export var nav_agent : NavigationAgent3D
@export var timer : Timer
@export var speed : float = 5.0
##stores the position to move to and the times (in seconds) when it happens
@export var moving_times : Dictionary[float, Marker3D]
##stores where should it move to, depending on the npc state
@export var moving_locations : Dictionary[Marker3D, gamestate]

var moving_towards : Marker3D = null
var current_state : states = states.IDLE
var current_gamestate : gamestate = gamestate.NORMAL
var current_event : float = 0.0

func _ready() -> void:
	timer.timeout.connect(start_walking)
	var expected_time : float = 6000
	for i : float in moving_times.keys():
		if i < expected_time:
			current_event = i
	timer.start(current_event)
	nav_agent.target_reached.connect(back_to_idle)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	match current_state:
		states.WALKING:
			#nav_agent.target_position = Vector3(moving_towards.global_position.x, global_position.y, moving_towards.global_position.z)
			nav_agent.target_position = moving_towards.global_position
			var destination : Vector3 = nav_agent.get_next_path_position()
			var local_destination : Vector3 = destination - global_position
			print_debug(local_destination)
			var direction : Vector3 = local_destination.normalized()
			if direction:
				look_at(global_position + direction, Vector3.UP)
			velocity = direction * speed
		states.IDLE:
			velocity = Vector3.ZERO
	move_and_stair_step()


func back_to_idle() -> void:
	current_state = states.IDLE
	animation_player.play("idle")


func start_walking() -> void:
	var possible_move : Marker3D = moving_times[current_event]
	if moving_locations[possible_move] == current_gamestate:
		moving_towards = possible_move
		current_state = states.WALKING
		animation_player.play("walk")

	var candidate_time : float = 6000
	for i : float in moving_times.keys():
		if i < candidate_time and i > Globals.current_time and i != current_event:
			candidate_time = i
	current_event = candidate_time
	timer.start(current_event)
