extends CharacterBody2D

signal ennemyDie(dropXp : float)
signal ennemyAttack(damage : float)

const SPEED = 150.0
var ennemyAttr : EnnemyData
var ennemyType : GameEnums.EnnemyType
var player : CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_raycast: RayCast2D = $RayCast2D

var spawnId = 0
var life = 1
var isAttacking = false
var can_attack = true

func _ready() -> void:
	anim.material = anim.material.duplicate()
	applySkin()


func init(type : GameEnums.EnnemyType, id : int, playerPos : CharacterBody2D):
	player = playerPos
	spawnId = id
	match type:
		GameEnums.EnnemyType.LIGHT: 
			ennemyAttr = load("res://Resources/Ennemy/light_ennemy.tres")
		GameEnums.EnnemyType.MEDIUM:
			ennemyAttr = load("res://Resources/Ennemy/medium_ennemy.tres")
		GameEnums.EnnemyType.HEAVY:
			ennemyAttr = load("res://Resources/Ennemy/heavy_ennemy.tres")
			
	life = ennemyAttr.life
	
func applySkin():
	anim.sprite_frames = ennemyAttr.sprite
	
func _process(delta: float) -> void:
	if anim.animation == "Attack":
		if anim.frame == 3:
			dealDamage()
	
func _physics_process(delta: float) -> void:
	
	var distance = position.distance_to(player.position)
	if	distance <= 100 && can_attack:
		attack()
	
	var direction = (player.position - position).normalized()
	if !isAttacking:
		anim.play("Walk")
		if direction.x < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
		velocity = direction * SPEED
		move_and_slide()
	
func attack():
	can_attack = false
	anim.play("Attack")
	isAttacking = true
	
			
func dealDamage():
	var direction = (player.position - position).normalized()

	attack_raycast.target_position = (direction * 100)
	attack_raycast.force_raycast_update()
	if attack_raycast.is_colliding():
		var collider = attack_raycast.get_collider()
		if collider.is_in_group("Player"):
			ennemyAttack.emit(ennemyAttr.damage)

func check_life():
	if life <= 0:
		ennemyDie.emit(ennemyAttr.drop_xp)	
		queue_free()
	else:
		hit_flash()

func hit_flash():
	for i in range(4):
		anim.material.set_shader_parameter("active", true)
		await get_tree().create_timer(0.08).timeout
		anim.material.set_shader_parameter("active", false)
		await get_tree().create_timer(0.08).timeout

func on_player_attack(damage : float, id : int):
	if id == spawnId:
		life -= damage
		check_life()
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "Attack":
		can_attack = true
		isAttacking = false
