extends CharacterBody2D

signal player_attack(damage : float)


const SPEED = 300.0
const MULT = 1.2

var can_light_attack = true
var level = 1
var next_level_xp = 10
var xp = 0

@export var anim: AnimatedSprite2D
@export var light_attack_timer: Timer
@onready var cam: Camera2D = $Camera2D
@onready var light_attack_raycast: RayCast2D = $light_attack_raycast


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && can_light_attack:
		light_attack()


func _physics_process(delta: float) -> void:
	
	var directionX := Input.get_axis("ui_left", "ui_right")
	var directionY := Input.get_axis("ui_up", "ui_down")
	var direction := Vector2(directionX, directionY).normalized()

	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else: 
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.x, 0, SPEED)


	move_and_slide()


func light_attack():
	can_light_attack = false

	var direction = Vector2(get_global_mouse_position() - global_position).normalized()
	light_attack_raycast.target_position = (direction * 100)
	if light_attack_raycast.is_colliding():
		print("ok")
	
	light_attack_timer.start()


func _on_light_attack_timer_timeout() -> void:
	can_light_attack = true
