extends Node2D

var player : CharacterBody2D


func _ready() -> void:
	player = get_node("Player")

func _on_child_entered_tree(node: Node) -> void:
	if node.is_in_group("Ennemy"):
		player.player_attack.connect(node.on_player_attack)
		node.ennemyDie.connect(player.on_ennemy_die)
