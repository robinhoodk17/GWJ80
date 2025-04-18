extends interactable

func interact(playermodel, _player_controller) -> void:
	if (Globals.current_time < 240.0 or Globals.current_time > 480.0) and !frozen_in_time:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		Dialogic.start("jaws_stop_that").process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		@warning_ignore("untyped_declaration")
		#Dialogic.timeline_ended.connect(func():get_tree().set('paused', false))
		get_tree().paused = true
	else:
		grab(playermodel, _player_controller)

func freeze_in_time() -> void:
	if (Globals.current_time < 240.0 or Globals.current_time > 480.0) and !frozen_in_time:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		Dialogic.start("jaws_stop_that").process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		@warning_ignore("untyped_declaration")
		#Dialogic.timeline_ended.connect(func():get_tree().set('paused', false))
		get_tree().paused = true
	else:
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
