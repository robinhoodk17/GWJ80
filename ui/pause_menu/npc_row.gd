extends VBoxContainer

@export var NPC_name : String = "vinny"

func _ready() -> void:
	Globals.on_quest_progress.connect(quest_progress)
	Globals.on_quest_end.connect(quest_end)

func quest_progress(quest_name) -> void:
	if quest_name == NPC_name:
		handle_progress(Globals.current_time)


func quest_end(quest_name) -> void:
	if quest_name == NPC_name:
		handle_end(Globals.current_time)

func handle_end(current_time) -> void:
	pass

func handle_progress(current_time) -> void:
	pass
