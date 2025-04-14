extends RichTextLabel

@export var time_freeze_action : GUIDEAction
@onready var time_travel_prompt: RichTextLabel = $"."

func _ready() -> void:
	Globals.found_item.connect(pop_up_show)
	Globals.lost_item.connect(turn_off_prompt)
	call_deferred("turn_off_prompt")

func turn_off_prompt() -> void:
	hide()


func pop_up_show() -> void:
	show()
	var formatter : GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts(30)
	@warning_ignore("untyped_declaration")
	var input_label  = await formatter.action_as_richtext_async(time_freeze_action)
	text = "press %s to decouple from \n the flow of time" % [input_label]
