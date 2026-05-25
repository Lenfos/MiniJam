extends CharacterBody2D

signal player_attack(damage : float, id : int)
signal level_up
signal level_up_gui(newLife : float, newStamina : int)
signal new_level
signal update_health(damage : float)
signal update_stamina(newStamina : int)
signal player_death

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var footstep_sound: AudioStreamPlayer = $AudioStreamPlayer

# Light Attack
@onready var light_attack_timer: Timer = $lightAttackTimer
@onready var light_attack_zone: Area2D = $lightAttackZone

# Heavy Attack
@onready var heavy_attack_zone: Area2D = $heavyAttackZone
@onready var heavy_attack_timer: Timer = $heavyAttackTimer

const SPEED = 300.0
const MULTXP = 1.2

# dino
const RAPTOR_DATA = preload("res://Resources/Player/player_raptor.tres")
const DILO_DATA = preload("res://Resources/Player/player_dilophosaur.tres")
const GALLIMINUS_DATA = preload("res://Resources/Player/player_galliminus.tres")
const TRICERATOPS_DATA = preload("res://Resources/Player/player_triceratops.tres")
const STEGOSAURE_DATA = preload("res://Resources/Player/player_stegosaure.tres")
const CROCODILE_DATA = preload("res://Resources/Player/player_crocodile.tres")
const REX_DATA = preload("res://Resources/Player/player_rex.tres")

# lightAttack
var can_light_attack = true
var isAttacking : bool = false

# heavyAttack
var can_heavy_attack = true
var usedHeavy = 0
var maxHeavy = 3

# animations
var playerAttr : CharacterData
var animSuffixe : String = "E"

# XP
var level = 1
var next_level_xp = 10
var xp = 0

var life
var dead = false


#region integrateFunction

func initialize() -> void:
	switchSkin()
	anim.animation_finished.connect(on_animation_finished)
	light_attack_timer.timeout.connect(_on_light_attack_timer_timeout)
	light_attack_zone.monitoring = false
	heavy_attack_zone.monitoring = false

	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") && can_light_attack && !isAttacking:
		light_attack()
	if event.is_action_pressed("ui_select") && can_heavy_attack && !isAttacking:
		heavyAttack()

func _physics_process(_delta: float) -> void:
	
	var directionX = Input.get_axis("ui_left", "ui_right")
	var directionY = Input.get_axis("ui_up", "ui_down")
	
	changeSuffixe(directionX, directionY)
	var direction := Vector2(directionX, directionY).normalized()
	
	if direction != Vector2.ZERO && !isAttacking:
		anim.play("Walk" + animSuffixe)
		if !footstep_sound.playing:
			footstep_sound.play()
		velocity = direction * SPEED
	else: 
		if !isAttacking:
			anim.play("Idle" + animSuffixe)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
		footstep_sound.stop()
	move_and_slide()

#endregion

#region animations

func switchSkin():
	print(level)
	match level:
		1:
			playerAttr = RAPTOR_DATA.duplicate(true)
			applySkin()
		10:
			playerAttr = DILO_DATA.duplicate(true)
			applySkin()
		20:
			playerAttr = GALLIMINUS_DATA.duplicate(true)
			applySkin()
		30:
			playerAttr = TRICERATOPS_DATA.duplicate(true)
			applySkin()
		40:
			playerAttr = STEGOSAURE_DATA.duplicate(true)
			applySkin()
		50:
			playerAttr = CROCODILE_DATA.duplicate(true)
			applySkin()
		60:
			playerAttr = REX_DATA.duplicate(true)
			applySkin()
	new_level.emit()

func applySkin():
	anim.sprite_frames = playerAttr.sprite_frames
	isAttacking = false
	can_light_attack = true
	can_heavy_attack = true
	usedHeavy = 0
	life = playerAttr.life
	if level != 1:
		level_up.emit()
	level_up_gui.emit(playerAttr.life, 3)
	
func changeSuffixe(directionX, directionY):
	if directionY > 0 && directionX <= 0.3 && directionX >= -0.3:
		animSuffixe = "S"
		collision.position = Vector2(5, 20)
	elif directionY < 0 && directionX <= 0.3 && directionX >= -0.3:
		animSuffixe = "N"
		collision.position = Vector2(0, 14)
	elif directionX > 0 && directionY <= 0.3 && directionY >= -0.3:
		animSuffixe = "E"
		collision.position = Vector2(9, 14)
	elif directionX < 0 && directionY <= 0.3 && directionY >= -0.3:
		animSuffixe = "W"
		collision.position = Vector2(-10, 14)
	
#endregion


func check_life():
	print(life)
	if life <= 0:
		isAttacking = true
		dead = true
		anim.play("Die")
		player_death.emit()
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
	


#region signalComeback
func on_ennemy_attack(ennemyDamage : float):
	if dead:
		return
	life -= abs(ennemyDamage)
	update_health.emit(abs(ennemyDamage))
	check_life()

func on_ennemy_die(dropXp : float):
	xp += dropXp
	check_xp()
	
func on_animation_finished():
	if anim.animation.begins_with("LightAttack"):
		isAttacking = false
		can_light_attack = true
	elif anim.animation.begins_with("HeavyAttack"):
		check_can_heavy()
		isAttacking = false
#endregion

#region lightAttack

func light_attack():
	can_light_attack = false
	isAttacking = true
	
	var direction = Vector2(get_global_mouse_position() - global_position).normalized()
	changeSuffixe(direction.x, direction.y)
	
	anim.play("LightAttack" + animSuffixe)
	
	light_attack_zone.rotation = direction.angle()
	light_attack_zone.monitoring = true
	light_attack_timer.start()
	

func _on_light_attack_timer_timeout() -> void:
	for body in light_attack_zone.get_overlapping_bodies():
		if body.is_in_group("Ennemy"):
			player_attack.emit(playerAttr.damageLight, body.spawnId)
	light_attack_zone.monitoring = false
	
#endregion

#region heavyAttack

func heavyAttack():
	can_heavy_attack = false
	isAttacking = true
	
	anim.play("HeavyAttack" + animSuffixe)
	usedHeavy += 1
	update_stamina.emit(maxHeavy - usedHeavy)
	
	heavy_attack_zone.monitoring = true
	heavy_attack_timer.start()
	
func _on_heavy_attack_timer_timeout() -> void:
	for body in heavy_attack_zone.get_overlapping_bodies():
		if body.is_in_group("Ennemy"):
			player_attack.emit(playerAttr.damageHeavy, body.spawnId)
	heavy_attack_zone.monitoring = false

func check_can_heavy():
	if usedHeavy >= maxHeavy:
		can_heavy_attack = false
	else:
		can_heavy_attack = true

#endregion
