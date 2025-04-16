extends Node3D

func _ready() -> void:
	$Timer.start()


func _on_timer_timeout() -> void:
	$"Dee Hive/AnimationPlayer".play("idle")
