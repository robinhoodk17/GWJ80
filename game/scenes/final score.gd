extends Label

@onready var label_2: Label = $"../Label2"
@onready var label_3: Label = $"../Label3"

func _ready() -> void:
	text = str("game finished! Your total karma was: %s", Globals.running_karma)
	label_2.text = str("you touched the life of %s animals", Globals.nice_quests + Globals.naughty_quests)
