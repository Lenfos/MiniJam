extends CharacterBody2D

signal ennemyDie(dropXp : float)
signal ennemyAttack(damage : float)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_raycast: RayCast2D = $RayCast2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_reset_timer: Timer = $hitResetTimer

const SPEED = 150.0
const LIGHT_ENNEMY_DATA = preload("res://Resources/Ennemy/light_ennemy.tres")
const MEDIUM_ENNEMY_DATA = preload("res://Resources/Ennemy/medium_ennemy.tres")
const HEAVY_ENNEMY_DATA = preload("res://Resources/Ennemy/heavy_ennemy.tres")

var ennemyAttr : EnnemyData
var ennemyType : GameEnums.EnnemyType
var player : CharacterBody2D
var knockback_velocity = Vector2.ZERO

var spawnId = 0
var life = 1
var isAttacking = false
var can_attack = true
var hit = false
var damageDealt = false

func _ready() -> void:
	anim.material = anim.material.duplicate()
	applySkin()

func init(type : GameEnums.EnnemyType, id : int, playerPos : CharacterBody2D):
	player = playerPos
	spawnId = id
	match type:
		GameEnums.EnnemyType.LIGHT:
			ennemyAttr = LIGHT_ENNEMY_DATA.duplicate(true)
		GameEnums.EnnemyType.MEDIUM:
			ennemyAttr = MEDIUM_ENNEMY_DATA.duplicate(true)
		GameEnums.EnnemyType.HEAVY:
			ennemyAttr = HEAVY_ENNEMY_DATA.duplicate(true)
			
	life = ennemyAttr.life
	
func applySkin():
	anim.sprite_frames = ennemyAttr.sprite
	
func _process(_delta: float) -> void:
	if anim.animation == "Attack":
		if anim.frame == 3 && !damageDealt:
			damageDealt = true
			dealDamage()
	
func _physics_process(delta: float) -> void:
	
	var distance = position.distance_to(player.position)
	if distance <= 70 && can_attack:
		attack()
		
	if hit:
		velocity = knockback_velocity
		move_and_slide()
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800 * delta)
		
	
	var direction = (player.position - position).normalized()
	if !isAttacking && !hit:
		anim.play("Walk")
		if direction.x < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
		velocity = direction * SPEED
		move_and_slide()
	
func attack():
	can_attack = false
	isAttacking = true
	anim.play("Attack")
	
			
func dealDamage():
	var direction = (player.position - position).normalized()

	attack_raycast.target_position = (direction * 70)
	attack_raycast.force_raycast_update()
	if attack_raycast.is_colliding():
		var collider = attack_raycast.get_collider()
		if collider.is_in_group("Player"):
			ennemyAttack.emit(ennemyAttr.damage)

func check_life():
	if life <= 1:
		anim.play("Die")
		ennemyDie.emit(ennemyAttr.drop_xp)
		z_index -= 1
	hit_flash()

func hit_flash():
	for i in range(4):
		anim.material.set_shader_parameter("active", true)
		await get_tree().create_timer(0.08).timeout
		anim.material.set_shader_parameter("active", false)
		await get_tree().create_timer(0.08).timeout
	

func on_player_attack(damage : float, id : int):
	if id == spawnId:
		var direction = (player.position - position).normalized() * -1
		knockback_velocity = direction * 400
		hit = true
		life -= abs(damage)
		hit_reset_timer.start()
		check_life()
	

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Attack":
		can_attack = true
		isAttacking = false
		damageDealt = false
	elif anim.animation == "Die":
		collision.disabled = true
		await get_tree().create_timer(1.3).timeout
		queue_free()


func _on_hit_reset_timer_timeout() -> void:
	if anim.animation != "Die":
		hit = false
