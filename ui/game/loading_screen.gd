extends CanvasLayer

signal finished_entering
signal finished_loading

func _ready() -> void:
	hide()

func start_load() -> void:
	show()
	$AnimationPlayer.play("enter")

func finish_entering() -> void:
	finished_entering.emit()

func finish_load() -> void:
	hide()
	#Globals.finished_loading()
	finished_loading.emit()

func start_animation() -> void:
	$AnimationPlayer.play("exit")
