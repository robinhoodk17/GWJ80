extends Node3D

@export var default_mapping_context: GUIDEMappingContext

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GUIDE.enable_mapping_context(default_mapping_context)
	await  get_tree().process_frame
	$UI.go_to("Game")
	$UI/Game/Label.start_counting = true
