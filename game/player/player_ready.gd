extends CharacterBody3D


func _ready() -> void:
	Globals.player_spawn_position = global_position
	Globals.player_spawn_rotation = global_basis
