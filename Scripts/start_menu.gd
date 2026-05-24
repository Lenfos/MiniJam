extends Control

@onready var play: TextureButton = $VBoxContainer/Play
@onready var quit: TextureButton = $VBoxContainer/Quit

var mainScene = "uid://c0ldbcvnikogf"

func _on_play_pressed() -> void:
	SceneManager.load_scene(mainScene)


func _on_quit_pressed() -> void:
	get_tree().quit()
