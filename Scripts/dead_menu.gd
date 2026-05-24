extends Control

@export var restart: TextureButton
@export var menu: TextureButton
@export var animation_player: AnimationPlayer


func _ready() -> void:
	restart.disabled = true
	menu.disabled = true


var startScene = "uid://ni0ekoth4iub"
var mainScene = "uid://c0ldbcvnikogf"

func _on_restart_pressed() -> void:
	SceneManager.load_scene(mainScene)

func _on_menu_pressed() -> void:
	SceneManager.load_scene(startScene)
	
func on_player_death():
	animation_player.play("transition")
	await animation_player.animation_finished
	
	restart.disabled = false
	menu.disabled = false
