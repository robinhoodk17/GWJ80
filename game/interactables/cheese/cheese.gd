extends interactable

@export var experiment_timer : Timer
@export var experiment_length : float = 120

func _ready() -> void:
	first_encounter = true
	Globals.restart.connect(on_restart)
	experiment_timer.start(experiment_length)
	experiment_timer.timeout.connect(can_interact_again)


func can_interact_again() -> void:
	can_interact = true
	global_position = Vector3(0, 1000,0)


func on_restart() -> void:
	drop()
	array_index = 0
	current_refresh = 0
	if frozen_in_time:
		return
	global_position = positions_array[array_index]
	global_basis = rotations_array[array_index]
	experiment_timer.start(experiment_length)
	can_interact = false
