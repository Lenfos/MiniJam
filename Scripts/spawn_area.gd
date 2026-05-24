extends Area2D


signal spawn_instance(ennemy : CharacterBody2D)

@export var ennemy : PackedScene
@onready var col: CollisionShape2D = $CollisionShape2D


var ennemyId
var scene

func _ready() -> void:
	ennemyId = 0
	scene = get_tree().current_scene
	

func spawn():
	var instance = ennemy.instantiate()
	instance.init(randomEnnemyType(), ennemyId, scene.get_node("Player"))
	instance.position = get_random_point_in_rect()
	
	scene.add_child(instance)
	spawn_instance.emit(instance)
	ennemyId += 1
	
func randomEnnemyType() -> GameEnums.EnnemyType:
	var ennemyType : GameEnums.EnnemyType
	var randomTypeNumber = randf()
	if randomTypeNumber <= 0.7:
		ennemyType = GameEnums.EnnemyType.LIGHT
	elif randomTypeNumber <= 0.9:
		ennemyType = GameEnums.EnnemyType.MEDIUM
	else:
		ennemyType = GameEnums.EnnemyType.HEAVY
	return ennemyType

func get_random_point_in_rect() -> Vector2:
	var shape := col.shape as RectangleShape2D
	var half_size := shape.size / 2.0

	var point := Vector2(
		randf_range(-half_size.x, half_size.x),
		randf_range(-half_size.y, half_size.y)
	)

	return col.to_global(point)


func _on_timer_timeout() -> void:
	spawn()
