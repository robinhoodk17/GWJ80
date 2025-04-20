extends NPC

@export var barry : NPC
var convinced_barry_quest : bool = false

func handle_dialogue_start(_player_controller) -> void:
	if barry.quest_started and !convinced_barry_quest:
		start_dialogue("mee_barry_quest")
		return
	if Globals.current_time < 360.0:
		start_dialogue("mee_looking_for_badge")
		return

	if Globals.current_time < 360.0:
		start_dialogue("mee_could_be_worse")
		return

func handle_dialogue_end(signal_argument : String) -> void:
	if signal_argument == "mee_union":
		convinced_barry_quest = true
		barry.quest_progressed()
