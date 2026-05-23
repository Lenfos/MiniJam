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
var life = 100

var directionX : float
var directionY : float

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var light_attack_timer: Timer
@onready var cam: Camera2D = $Camera2D
@onready var light_attack_raycast: RayCast2D = $light_attack_raycast
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	switchSkin()
	anim.animation_finished.connect(on_animation_finished)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && can_light_attack:
		light_attack()

func switchSkin():
	print(level)
	match level:
		1: 
			playerAttr = load("res://Resources/Player/player_raptor.tres")
			applySkin()
		10:
			playerAttr = load("res://Resources/Player/player_dilophosaur.tres")
			applySkin()

func applySkin():
	anim.sprite_frames = playerAttr.sprite_frames
	isAttacking = false
	can_light_attack = true
	life = playerAttr.life
	
func _process(delta: float) -> void:
	if directionX > 0 && directionY >= 0:
		animSuffixe = "E"
		collision.position = Vector2(9, 14)
	elif directionX < 0 && directionY <= 0:
		animSuffixe = "W"
		collision.position = Vector2(-10, 14)
	elif directionY > 0 && directionX == 0:
		animSuffixe = "S"
		collision.position = Vector2(5, 20)
	elif directionY < 0 && directionX == 0:
		animSuffixe = "N"
		collision.position = Vector2(0, 14)

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
		velocity.y = move_toward(velocity.y, 0, SPEED)


	move_and_slide()


func light_attack():
	can_light_attack = false
	anim.play("LightAttack" + animSuffixe)
	isAttacking = true
	directionX = 0
	directionY = 0

	var direction = Vector2(get_global_mouse_position() - global_position).normalized()
	light_attack_raycast.target_position = (direction * playerAttr.lightRayLength)
	light_attack_raycast.force_raycast_update()
	if light_attack_raycast.is_colliding():
		var collider = light_attack_raycast.get_collider()
		if collider.is_in_group("Ennemy"):
			player_attack.emit(playerAttr.damageLight, collider.spawnId)

func on_ennemy_attack(ennemyDamage : float):
	life -= ennemyDamage
	check_life()


func check_life():
	if life <= 0:
		get_tree().paused = true
	else:
		hit_flash()
		
func hit_flash():
	for i in range(4):
		anim.material.set_shader_parameter("active", true)
		await get_tree().create_timer(0.08).timeout
		anim.material.set_shader_parameter("active", false)
		await get_tree().create_timer(0.08).timeout
	
func check_xp():
	if xp >= next_level_xp:
		level += 1
		next_level_xp = next_level_xp * MULTXP
		xp = 0
		switchSkin()
	
func on_ennemy_die(dropXp : float):
	xp += dropXp
	check_xp()
	
	
func on_animation_finished():
	isAttacking = false
	can_light_attack = true
