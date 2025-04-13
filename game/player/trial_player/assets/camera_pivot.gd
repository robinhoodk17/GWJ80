extends Node3D

@export_category("GUIDE actions")
@export var move_action : GUIDEAction
@export var fly_action : GUIDEAction
@export var camera_control : GUIDEAction
@export var interact_action : GUIDEAction

@export_category("Player Movement")
@export var speed := 5.0
@export var jump_velocity := 2.5
@export var hover_delay : float = 0.25
const ROTATION_SPEED := 6.0
@export_category("Camera controls")
@export var offset : Vector3 = Vector3(0.0, 1.5, 0.0)

#slowly rotate the charcter to point in the direction of the camera_pivot
@onready var playermodel : Node3D = $"../playermodel"
@onready var hover_timer: Timer = $HoverTimer

enum animation_state {IDLE,WALKING,JUMPING}
var player_animation_state : animation_state = animation_state.IDLE
@onready var animation_player: AnimationPlayer = $"../playermodel/Butterfly/AnimationPlayer"
@onready var player: CharacterBody3D = $".."
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var interaction_detection: Area3D = $"../playermodel/InteractionDetection"

var original_position : Vector3
var original_rotation : Basis
var dampened_y_array : Array[float] = [0.0, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0, 0.0, 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
var current_y : int = 0
var averaged_y : float = 0.0
func  _ready() -> void:
	Globals.restart.connect(restarted)
	await get_tree().process_frame
	original_position = player.global_position
	original_rotation = player.global_basis
	for i : int in range(dampened_y_array.size()):
		dampened_y_array[i] = original_position.y
		averaged_y = original_position.y


func _physics_process(delta: float) -> void:
	dampened_y_array[current_y] = player.global_position.y
	current_y = (current_y + 1) % dampened_y_array.size()
	var running_sum : float = 0.0
	for i in dampened_y_array:
		running_sum += i
	averaged_y = running_sum/dampened_y_array.size()
	var target_camera_position = Vector3(player.global_position.x, averaged_y, player.global_position.z)
	global_position = lerp(global_position, target_camera_position + offset, delta * 10.0)
	var camera_rotation = camera_control.value_axis_2d
	if camera_rotation:
		rotate_y(camera_rotation.x * Globals.sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x - camera_rotation.y,-0.6,0.4)
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	
	if fly_action.value_bool:
		if hover_timer.is_stopped():
			player.velocity.y = 0.0
	if fly_action.is_triggered():
		player.velocity.y = jump_velocity
		hover_timer.start(hover_delay)
		
	var talk : Dictionary = {"talk_started" : false, "npc" : null, "talk_result" : NPC.gamestate.NORMAL}
	if interact_action.is_triggered():
		if interaction_detection.showing_which != null:
			interaction_detection.showing_which.interact()
	var frame_info : Dictionary = {"position" : player.global_position, "rotation" : playermodel.global_basis, "talk" : talk}
	Globals.append_frame_data(frame_info)
	
	#I added this Vector.ZERO because otherwise, the player keeps the last input after you unpause
	var input_dir : Vector2 = Vector2.ZERO
	if move_action.value_axis_2d:
		input_dir = move_action.value_axis_2d
	var direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		player.velocity.x = direction.x * speed
		player.velocity.z = direction.z * speed
		#now rotate the model
		rotate_model(direction, delta)
		player_animation_state = animation_state.WALKING
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		player.velocity.z = move_toward(player.velocity.z, 0, speed)
		player_animation_state = animation_state.IDLE
	
	if not player.is_on_floor():
		player_animation_state = animation_state.JUMPING
	
	player.move_and_slide()
	#tell the playeranimationcontroller about the animation state
	match player_animation_state:
		animation_state.IDLE:
			animation_player.play("idle")
		animation_state.WALKING:
			animation_player.play("walk")
		animation_state.JUMPING:
			animation_player.play("flap")


func rotate_model(direction: Vector3, delta : float) -> void:
	#rotate the model to match the springarm
	playermodel.basis = lerp(playermodel.basis, Basis.looking_at(direction), 10.0 * delta)


func  restarted() -> void:
	player.global_position = original_position
	player.global_basis = original_rotation
