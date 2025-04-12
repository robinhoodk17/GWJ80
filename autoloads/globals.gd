extends Node

# What goes into globals.gd?
# If the function depends on the something in the game, it's a global.
# If it's independent, it (probably) belongs in utils.gd
@warning_ignore("unused_signal")
signal restart
var run_number : int = 1
var run_limit : int = 3
var current_time : float = 0.0
var first_run : Array[Dictionary]
var second_run : Array[Dictionary]
const PREWRITTEN_CONTROLLER = preload("res://game/player/prewritten_controller.tscn")
const PLAYER = preload("res://addons/srcoder_thirdperson_controller/player.tscn")

## Use UI/MessageBox to display a status update message to the player
@warning_ignore("unused_signal")
signal post_ui_message(text: String)

## Emitted by UI/Controls when a action is remapped
@warning_ignore("unused_signal")
signal controls_changed(config: GUIDERemappingConfig)

var player_spawn_position : Vector3
var player_spawn_rotation : Basis

func _restart() -> void:
	run_number += 1
	if run_number > run_limit:
		get_tree().change_scene_to_file("res://game/scenes/results_page.tscn")
		return
	var new_player = PLAYER.instantiate()
	get_tree().root.add_child(new_player)
	new_player.global_position = player_spawn_position
	new_player.global_basis = player_spawn_rotation
	var new_controller = PREWRITTEN_CONTROLLER.instantiate()
	match run_number -1:
		1:
			new_controller.frame_info = first_run
		2:
			new_controller.frame_info = second_run
	new_player.add_child(new_controller)
	current_time = 0.0
	restart.emit()


func append_frame_data(frame_data : Dictionary) -> void:
	match run_number:
		1:
			first_run.append(frame_data)
		2:
			second_run.append(frame_data)
		3:
			return
