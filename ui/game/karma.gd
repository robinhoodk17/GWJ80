extends RichTextLabel

func _ready() -> void:
	Globals.on_quest_end.connect(updateKarma)
	hide()

func updateKarma(_quest_name) -> void:
	show()
	await get_tree().create_timer(3).timeout
	text = "karma:  %s"  % [Globals.running_karma]
	await get_tree().create_timer(3).timeout
	hide()
