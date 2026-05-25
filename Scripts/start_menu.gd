extends Control

@export var play: TextureButton
@export var quit: TextureButton


var mainScene = "uid://c0ldbcvnikogf"

func _on_play_pressed() -> void:
	SceneManager.load_scene(mainScene)


func _on_quit_pressed() -> void:
	get_tree().quit()
