extends Camera2D

@export var player: Node2D
@export var smooth_position := 5.0

func _physics_process(delta: float) -> void:
	global_position = global_position.lerp(player.global_position, delta * smooth_position)
