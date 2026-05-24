extends Node2D

var player : CharacterBody2D
var spawnArea : Area2D

var lightEnemy : EnnemyData
var mediumEnemy : EnnemyData
var heavyEnemy : EnnemyData
var listEnnemyType

func _ready() -> void:
	player = get_node("Player")
	player.level_up.connect(on_player_level_up)
	
	spawnArea = get_node("SpawnArea")
	
	if spawnArea != null:
		spawnArea.spawn_instance.connect(on_new_instance)
		
	
	lightEnemy = load("res://Resources/Ennemy/light_ennemy.tres")
	mediumEnemy = load("res://Resources/Ennemy/medium_ennemy.tres")
	heavyEnemy = load("res://Resources/Ennemy/heavy_ennemy.tres")
	listEnnemyType = [lightEnemy, mediumEnemy, heavyEnemy]


func on_player_level_up():
	for enemy in listEnnemyType:
		enemy.life *= 1.25
		enemy.damage *= 1.25
		enemy.drop_xp *= 1.25

func on_new_instance(ennemy : CharacterBody2D):
	if !ennemy.ennemyAttack.is_connected(player.on_ennemy_attack):
		player.player_attack.connect(ennemy.on_player_attack)
		ennemy.ennemyDie.connect(player.on_ennemy_die)
		ennemy.ennemyAttack.connect(player.on_ennemy_attack)
