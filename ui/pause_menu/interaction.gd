extends TextureButton

@onready var tooltip: Label = $Label


func _ready() -> void:
	focus_entered.connect(show_tooltip)
	focus_exited.connect(hide_tooltip)
	mouse_entered.connect(show_tooltip)
	mouse_exited.connect(hide_tooltip)
	
	tooltip.hide()

func show_tooltip() -> void:
	tooltip.show()

func hide_tooltip() -> void:
	tooltip.hide()
