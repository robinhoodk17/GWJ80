extends Node3D
class_name player_controller

@export_category("GUIDE actions")
@export var time_freeze : GUIDEAction
@export var move_action : GUIDEAction
@export var fly_action : GUIDEAction
@export var camera_control : GUIDEAction
@export var interact_action : GUIDEAction
@export var reset_camera : GUIDEAction

@export_category("Player Movement")
@export var speed : float = 3.0
@export var gliding_speed : float = 7.0
@export var jump_velocity : float= 3.5
@export var hover_delay : float = 0.35
const ROTATION_SPEED : float = 6.0
@export_category("Camera controls")
@export var offset : Vector3 = Vector3(0.0, 1.5, 0.0)
#@onready var look_at_target: Node3D = $"../LookAtTarget"
@onready var camera_framing: Area3D = $SpringArm3D/Camera3D/CameraFraming
@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D
@onready var camera_timer: Timer = $CameraTimer
var camera_delay : float = .75
var reset_action_current_cooldown : float = 0.0
var reset_action_cooldown : float = .75
var reset_duration : float = 0.2
var _target_rotation : Vector3 = Vector3.ZERO
var reset_tween : Tween
var reset_position_tween : Tween
@export_subgroup("Item Manipulation")
var grabbing : interactable

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
	top_level = true
	time_freeze.triggered.connect(handle_time_freeze)
	fly_action.triggered.connect(handle_jump)
	interact_action.triggered.connect(handle_interaction)
	Globals.restart.connect(restarted)
	await get_tree().process_frame
	original_position = player.global_position
	original_rotation = player.global_basis
	for i : int in range(dampened_y_array.size()):
		dampened_y_array[i] = original_position.y
		averaged_y = original_position.y


func _physics_process(delta: float) -> void:
	var current_speed : float = speed
	if reset_action_current_cooldown < reset_action_cooldown:
		reset_action_current_cooldown += delta
	dampened_y_array[current_y] = player.global_position.y
	current_y = (current_y + 1) % dampened_y_array.size()
	var running_sum : float = 0.0
	for i : float in dampened_y_array:
		running_sum += i
	averaged_y = running_sum/dampened_y_array.size()
	if camera_framing.get_overlapping_bodies().size() == 0:
		var target_camera_position : Vector3 = Vector3(player.global_position.x, averaged_y, player.global_position.z)
		global_position = lerp(global_position, target_camera_position + offset, delta * 5.0)
		camera_timer.start(camera_delay)
		#var target_basis : Basis = camera_3d.global_basis.looking_at(look_at_target.global_position)
		#camera_3d.global_basis.slerp(target_basis, delta * 10.0)
	elif !camera_timer.is_stopped():
		var target_camera_position : Vector3 = Vector3(player.global_position.x, averaged_y, player.global_position.z)
		global_position = lerp(global_position, target_camera_position + offset, delta * 5.0)
		#var target_basis : Basis = camera_3d.global_basis.looking_at(look_at_target.global_position)
		#camera_3d.global_basis.slerp(target_basis, delta)
	#camera_3d.look_at(look_at_target.global_position)
	if reset_camera.is_triggered() and reset_action_current_cooldown >= reset_action_cooldown:
		reset_action_current_cooldown = 0.0
		position_camera_behind_player()
	var camera_rotation : Vector2 = camera_control.value_axis_2d
	if camera_rotation and !(reset_tween and reset_tween.is_running()):
		rotate_y(camera_rotation.x * Globals.sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x - camera_rotation.y,-0.6,0.4)
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta / Globals.time_scale

	
	if fly_action.value_bool:
		if hover_timer.is_stopped():
			player.velocity.y = 0.0
			current_speed = gliding_speed
	#if fly_action.is_triggered():
		#player.velocity.y = jump_velocity
		#hover_timer.start(hover_delay)
		
	var talk : Dictionary = {"talk_started" : false, "npc" : null, "talk_result" : NPC.gamestate.NORMAL}
	#if time_freeze.is_triggered():
		#if interaction_detection.showing_which != null:
			#if interaction_detection.showing_which.is_in_group("item"):
				#interaction_detection.showing_which.freeze_in_time()
	#if interact_action.is_triggered():
		#if interaction_detection.showing_which != null:
			#interaction_detection.showing_which.interact(playermodel, self)
		#else:
			#if grabbing != null:
				#grabbing.drop()
				#grabbing = null
	var frame_info : Dictionary = {"position" : player.global_position, "rotation" : playermodel.global_basis, "talk" : talk}
	Globals.append_frame_data(frame_info)
	
	#I added this Vector.ZERO because otherwise, the player keeps the last input after you unpause
	var input_dir : Vector2 = Vector2.ZERO
	if move_action.value_axis_2d:
		input_dir = move_action.value_axis_2d
		if !camera_timer.is_stopped():
			camera_timer.start(camera_delay)
	var direction : Vector3 = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() / Globals.time_scale
	
	if direction:
		player.velocity.x = direction.x * current_speed
		player.velocity.z = direction.z * current_speed
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


func position_camera_behind_player() -> void:
	_tween_rotation(playermodel.get_rotation().y,  reset_duration)


func _tween_rotation(target_y_rotation : float, duration : float = reset_duration) -> void:
	_target_rotation.y = wrapf(target_y_rotation, rotation.y - PI, rotation.y + PI)
	if reset_tween and reset_tween.is_running():
		reset_tween.kill()
	reset_tween = create_tween()
	reset_tween.tween_property(self, "rotation", _target_rotation, duration)
	var target_position : Vector3 = player.global_position + offset
	if reset_position_tween and reset_position_tween.is_running():
		reset_position_tween.kill()
	reset_position_tween = create_tween()
	reset_position_tween.tween_property(self, "global_position", target_position, duration)
	


func rotate_model(direction: Vector3, delta : float) -> void:
	#rotate the model to match the springarm
	playermodel.basis = lerp(playermodel.basis, Basis.looking_at(direction), 10.0 * delta)


func restarted() -> void:
	player.global_position = original_position
	player.global_basis = original_rotation


func handle_time_freeze() -> void:
	if interaction_detection.showing_which != null:
		if interaction_detection.showing_which.is_in_group("item"):
			if !interaction_detection.showing_which.freezable:
				return
			interaction_detection.showing_which.freeze_in_time()


func handle_jump() -> void:
	player.velocity.y = jump_velocity
	hover_timer.start(hover_delay)


func handle_interaction() -> void:
	if interaction_detection.showing_which != null:
		interaction_detection.showing_which.interact(playermodel, self)
	else:
		if grabbing != null:
			grabbing.drop()
			grabbing = null
