extends Node3D

@export var interact_action : GUIDEAction
@onready var label: RichTextLabel = $SubViewport/Label
@onready var sub_viewport: SubViewport = $SubViewport
@onready var sprite_3d: Sprite3D = $Sprite3D

func _ready() -> void:
	sprite_3d.texture = sub_viewport.get_texture()
	call_deferred("turn_off_prompt")

func turn_off_prompt() -> void:
	hide()


func pop_up_show() -> void:
	show()
	var formatter : GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts(100)
	@warning_ignore("untyped_declaration")
	var input_label  = await formatter.action_as_richtext_async(interact_action)
	label.text = "[center]%s[center]" % [input_label]
