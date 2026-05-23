extends CharacterBody2D

signal ennemyDie(dropXp : float)

const SPEED = 300.0

@export var spawnId = 0

func _ready() -> void:
	print(spawnId)
	
func on_player_attack(damage : float, id : int):
	if id == spawnId:
		print("Received")
