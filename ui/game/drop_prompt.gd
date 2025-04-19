extends VBoxContainer

func _ready() -> void:
	Globals.item_grabbed.connect(show)
	Globals.item_dropped.connect(hide)
	hide()
