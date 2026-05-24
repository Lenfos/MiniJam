extends Node2D

signal level_up_health(newLife : float)
signal level_up_stamina(newStamina : float)
signal update_health(damage : float)
signal update_stamina(stamina : float)
signal initialize_player()
signal player_dead

var player : CharacterBody2D
var spawnArea : Area2D

var lightEnemy : EnnemyData
var mediumEnemy : EnnemyData
var heavyEnemy : EnnemyData
var listEnnemyType

@onready var playerStatus: Control = $CanvasLayer/Control/HealthBar
@onready var dead_menu: Control = $CanvasLayer/Control/DeadMenu


func _ready() -> void:
	player = get_node("Player")
	player.level_up.connect(on_player_level_up)
	player.level_up_gui.connect(on_player_level_up_gui)
	player.update_health.connect(on_player_update_life)
	player.update_stamina.connect(on_player_update_stamina)
	player.player_death.connect(player_death)
	initialize_player.connect(player.initialize)
	
	level_up_health.connect(playerStatus.on_player_max_health_changed_progress)
	level_up_stamina.connect(playerStatus.on_player_max_stamina_changed_progress)
	update_health.connect(playerStatus.on_player_health_changed_progress)
	update_stamina.connect(playerStatus.on_player_stamina_changed_progress)
	
	player_dead.connect(dead_menu.on_player_death)
	
	spawnArea = get_node("SpawnArea")
	
	if spawnArea != null:
		spawnArea.spawn_instance.connect(on_new_instance)
		
	
	lightEnemy = load("res://Resources/Ennemy/light_ennemy.tres")
	mediumEnemy = load("res://Resources/Ennemy/medium_ennemy.tres")
	heavyEnemy = load("res://Resources/Ennemy/heavy_ennemy.tres")
	listEnnemyType = [lightEnemy, mediumEnemy, heavyEnemy]
	
	initialize_player.emit()


func on_player_level_up():
	for enemy in listEnnemyType:
		enemy.life *= 1.25
		enemy.damage *= 1.25
		enemy.drop_xp *= 1.25
	
func on_player_level_up_gui(newLife : float, newStamina : int):
	level_up_health.emit(newLife)
	level_up_stamina.emit(newStamina)
	
func on_player_update_life(damage : float):
	update_health.emit(damage)

func on_player_update_stamina(newStam : int):
	update_stamina.emit(newStam)

func on_new_instance(ennemy : CharacterBody2D):
	if !ennemy.ennemyAttack.is_connected(player.on_ennemy_attack):
		player.player_attack.connect(ennemy.on_player_attack)
		ennemy.ennemyDie.connect(player.on_ennemy_die)
		ennemy.ennemyAttack.connect(player.on_ennemy_attack)

func player_death():
	player_dead.emit()
