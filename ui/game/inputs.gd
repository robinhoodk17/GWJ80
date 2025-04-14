extends RichTextLabel

@export var action : GUIDEAction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("update_label")


func update_label() -> void:
	show()
	var formatter : GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts(30)
	@warning_ignore("untyped_declaration")
	var input_label  = await formatter.action_as_richtext_async(action)
	text = "[center]%s[center]" % [input_label]
