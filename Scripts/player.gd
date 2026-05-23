extends CharacterBody2D

signal player_attack(damage : float, id : int)

const SPEED = 300.0
const MULTXP = 1.2

var can_light_attack = true
var level = 1
var next_level_xp = 10
var xp = 0
var playerAttr : CharacterData
var animSuffixe : String = "E"
var isAttacking : bool = false

var directionX : float
var directionY : float

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var light_attack_timer: Timer
@onready var cam: Camera2D = $Camera2D
@onready var light_attack_raycast: RayCast2D = $light_attack_raycast


func _ready() -> void:
	switchSkin()
	anim.animation_finished.connect(on_animation_finished)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && can_light_attack:
		light_attack()

func switchSkin():
	match level:
		1: 
			playerAttr = load("res://Resources/Player/player_raptor.tres")
			applySkin()

func applySkin():
	anim.sprite_frames = playerAttr.sprite_frames
	
func _process(delta: float) -> void:
	if directionX > 0 && directionY >= 0:
		animSuffixe = "E"
	elif directionX < 0 && directionY <= 0:
		animSuffixe = "W"
	elif directionY > 0 && directionX == 0:
		animSuffixe = "S"
	elif directionY < 0 && directionX == 0:
		animSuffixe = "N"

func _physics_process(delta: float) -> void:
	
	directionX = Input.get_axis("ui_left", "ui_right")
	directionY = Input.get_axis("ui_up", "ui_down")
	var direction := Vector2(directionX, directionY).normalized()

	
	if direction != Vector2.ZERO && !isAttacking:
		anim.play("Walk" + animSuffixe)
		velocity = direction * SPEED
	else: 
		if !isAttacking:
			anim.play("Idle" + animSuffixe)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.x, 0, SPEED)


	move_and_slide()


func light_attack():
	can_light_attack = false
	anim.play("LightAttack" + animSuffixe)
	isAttacking = true
	directionX = 0
	directionY = 0

	var direction = Vector2(get_global_mouse_position() - global_position).normalized()
	light_attack_raycast.target_position = (direction * playerAttr.lightRayLength)
	if light_attack_raycast.is_colliding():
		player_attack.emit(10, 0)


func check_xp():
	if xp >= next_level_xp:
		level += 1
		switchSkin()
		

func on_ennemy_die(dropXp : float):
	xp += dropXp
	
	
func on_animation_finished():
	isAttacking = false
	can_light_attack = true
