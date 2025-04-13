extends Node3D

@export_category("GUIDE actions")
@export var move_action : GUIDEAction
@export var fly_action : GUIDEAction
@export var camera_control : GUIDEAction
@export var interact_action : GUIDEAction

@export_category("Player Movement")
@export var speed := 5.0
@export var jump_velocity := 4.5
const ROTATION_SPEED := 6.0

#slowly rotate the charcter to point in the direction of the camera_pivot
@onready var playermodel : Node3D = $"../playermodel"

enum animation_state {IDLE,RUNNING,JUMPING}
var player_animation_state : animation_state = animation_state.IDLE
@onready var animation_player : AnimationPlayer = $"../playermodel/character-male-e2/AnimationPlayer"
@onready var player: CharacterBody3D = $".."
@onready var spring_arm: SpringArm3D = $SpringArm3D

var original_position : Vector3
var original_rotation : Basis

func  _ready() -> void:
	Globals.restart.connect(restarted)
	await get_tree().process_frame
	original_position = player.global_position
	original_rotation = player.global_basis


func _physics_process(delta: float) -> void:
	var camera_rotation = camera_control.value_axis_2d
	if camera_rotation:
		rotate_y(camera_rotation.x * Globals.sensitivity)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x - camera_rotation.y,-0.6,0.4)
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta

	# Handle jump.
	if fly_action.is_triggered():
		player.velocity.y = jump_velocity
		
	var talk : Dictionary = {"talk_started" : false, "npc" : null, "talk_result" : NPC.gamestate.NORMAL}
	if interact_action.is_triggered():
		pass
	var frame_info : Dictionary = {"position" : player.global_position, "rotation" : playermodel.global_basis, "talk" : talk}
	Globals.append_frame_data(frame_info)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := move_action.value_axis_2d
	var direction = (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * speed
		player.velocity.z = direction.z * speed
		#now rotate the model
		rotate_model(direction, delta)
		player_animation_state = animation_state.RUNNING
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
		animation_state.RUNNING:
			animation_player.play("sprint")
		animation_state.JUMPING:
			animation_player.play("jump")


func rotate_model(direction: Vector3, delta : float) -> void:
	#rotate the model to match the springarm
	playermodel.basis = lerp(playermodel.basis, Basis.looking_at(direction), 10.0 * delta)


func  restarted():
	player.global_position = original_position
	player.global_basis = original_rotation
