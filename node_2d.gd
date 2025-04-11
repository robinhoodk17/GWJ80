extends Control

@export var jump_action:GUIDEAction

# The formatter that we will use to get the input prompt string.
@export var mapping_context: GUIDEMappingContext
@onready var _formatter:GUIDEInputFormatter = GUIDEInputFormatter.for_context(mapping_context)
var _remapper: GUIDERemapper = GUIDERemapper.new()
var _remapping_config: GUIDERemappingConfig
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_prompt_label()
func update_prompt_label():
	var action_text:String = await _formatter.action_as_richtext_async(jump_action)
	$RichTextLabel.parse_bbcode(tr("%s to [b]jump[/b]") % [action_text])
