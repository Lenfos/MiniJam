extends Control

@onready var health_progress_bar: TextureProgressBar = $TextureRect/healthProgressBar
@onready var stamina_progress_bar: TextureProgressBar = $TextureRect/StaminaProgressBar

var playerLife = 100
var playerMaxLife = 100

var playerMaxStamina = 3
var playerStamina = 3

func on_player_health_changed_progress(damage : float):
	playerLife -= damage
	health_progress_bar.value = playerLife / playerMaxLife
	
func on_player_max_health_changed_progress(newLife : float):
	playerMaxLife = newLife
	playerLife = newLife
	health_progress_bar.value = 1
	print("enfoire")

	
func on_player_stamina_changed_progress(newStamina : float):
	playerStamina = newStamina
	stamina_progress_bar.value = playerStamina / playerMaxStamina

func on_player_max_stamina_changed_progress(newStamina : float):
	playerMaxStamina = newStamina
	playerStamina = playerMaxStamina
	stamina_progress_bar.value = 1
