extends CharacterBody3D
class_name interactable
enum item_type{CHEESE, LETTER, PIGGY, FILES, BADGE, ROLLERBLADES, MAIL}
@export var already_interacted : bool = false
@export var freezable : bool = false
@export var affected_by_time : bool = true
@export var can_interact : bool = true
@export var type : item_type = item_type.CHEESE
@onready var pop_up: Node3D = $PopUp
@onready var quest_finished : bool = false

var frozen_in_time : bool = false
var first_encounter : bool = false
var player_model : Node3D
var grabbed : bool = false
var positions_array : Array[Vector3]
var rotations_array : Array[Basis]
var array_index : int = 0
var current_refresh : int = 0

func _ready() -> void:
	first_encounter = true
	Globals.restart.connect(on_restart)


func _physics_process(delta: float) -> void:
	if current_refresh == 0 and !frozen_in_time:
		array_index += 1
		if array_index < positions_array.size():
			global_position = positions_array[array_index - 1]
			global_basis = rotations_array[array_index - 1]
		else:
			positions_array.append(global_position)
			rotations_array.append(global_basis)
	current_refresh = (current_refresh + 1) % Globals.item_refresh_rate

	if !grabbed and (array_index >= positions_array.size() or frozen_in_time):
		velocity += get_gravity() * delta
		move_and_slide()

	if grabbed:
		global_position = player_model.global_position - player_model.basis.z
		velocity = Vector3.ZERO
		if array_index < positions_array.size():
			var temporal : Array[Vector3] = positions_array.duplicate()
			var temporal2 : Array [Basis] = rotations_array.duplicate()
			positions_array.clear()
			rotations_array.clear()
			for i : int in array_index:
				positions_array.append(temporal[i])
				rotations_array.append(temporal2[i])


func freeze_in_time() -> void:
	frozen_in_time = true

	Globals.lost_item.emit()
	first_encounter = false

	positions_array.clear()
	rotations_array.clear()
	for i : int in array_index:
		positions_array.append(global_position)
		rotations_array.append(global_basis)
	Dialogic.start("freeze_in_time").process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	@warning_ignore("untyped_declaration")
	Dialogic.timeline_ended.connect(func():get_tree().set('paused', false))
	get_tree().paused = true



func interact(playermodel : Node3D, _player_controller : player_controller) -> void:
	grab(playermodel, _player_controller)
	
func grab(_player_model : Node3D, _player_controller : player_controller) -> void:
	if quest_finished:
		#Dialogic.start("butterfly_council").process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.start("butterfly_council")
		return
		#Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		#@warning_ignore("untyped_declaration")
		#Dialogic.timeline_ended.connect(func():get_tree().set('paused', false))
		#get_tree().paused = true
		
	if _player_controller.grabbing != null:
		_player_controller.grabbing.drop()
	_player_controller.grabbing = self
	collision_layer = 0
	collision_mask = 0
	player_model = _player_model
	grabbed = true
	Globals.item_grabbed.emit()


func drop() -> void:
	global_position = global_position + Vector3.UP
	collision_layer = 4
	collision_mask = 1
	grabbed = false
	Globals.item_dropped.emit()


func display_prompt() -> void:
	if first_encounter and freezable:
		Globals.found_item.emit()
	if pop_up:
		if pop_up.visible:
			return
		pop_up.pop_up_show()


func turn_off_prompt() -> void:
	first_encounter = false
	Globals.lost_item.emit()
	#%TimeTravelPrompt.turn_off_prompt()
	if pop_up:
		pop_up.turn_off_prompt()


func on_restart() -> void:
	drop()
	array_index = 0
	current_refresh = 0
	if frozen_in_time:
		return
	global_position = positions_array[array_index]
	global_basis = rotations_array[array_index]
