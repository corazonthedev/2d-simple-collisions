extends CharacterBody2D


@onready var anim = $AnimationPlayer
@onready var HitArea = $HitArea/AnimationAttack


#movement-----------------------------------------------------------------------
var speed = 100
var friction = 10 #DECREASES SPEED 
#health-------------------------------------------------------------------------
var health = 10
					###var can_get_damage = true 
var recently_taken_damage = false
#-------------------------------------------------------------------------------
#global.p_target_inattack_range = false #for player attack ON GLOBAL p_target_inattack_range
#global.p_attack_cooldown = true #for player attack ON GLOBAL p_attack_cooldown
#--------------------------------
var enemy_in_damagerange = false #for enemy attack 
var enemy_damage_cooldown = true #for enemy attack 
					###var can_attack = true
#utils--------------------------------------------------------------------------
var lastPressedMoveKey = ""
var lookingDirection = ""
var lastAnim = ""
					###var can_change_lookDirection = true
#-------------------------------------------------------------------------------
func _ready():
	hand()



func _physics_process(_delta):
	moveAnimation()
	
	player_attack()
	
	hurting()
	dying()
	
	move_and_slide()

func player():
	pass

#--------MOVING-----------------------------------------------------------------
func moveAnimation():
	var moveDirection = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = moveDirection * speed
	if velocity.length() == 0:
		if lastAnim != "Hit":
			if anim.is_playing():
				anim.stop()
	else:
		if Input.is_action_pressed("ui_up"): lastPressedMoveKey = "Up" 
		if Input.is_action_pressed("ui_down"): lastPressedMoveKey = "Down"
		if Input.is_action_pressed("ui_right"): lastPressedMoveKey = "Right"
		if Input.is_action_pressed("ui_left"): lastPressedMoveKey = "Left"
		anim.play(lastPressedMoveKey)
		lookingDirection = lastPressedMoveKey
		lastAnim = lastPressedMoveKey
#-------------------------------------------------------------------------------


#---------PLAYER_TAKING_DAMAGE--------------------------------------------------
func hurting():
	if global.e_is_attacking_target == true:
		health -= global.e_attack_power
		print("player health = " , health)
		anim.play("Hit") #-----------Hit Down-Up-Right-Left WILL BE ADDED---------------------------
		lastAnim = "Hit"
		global.e_is_attacking_target = false
#-------------------------------------------------------------------------------


#---------PLAYER_DYING----------------------------------------------------------
func dying():
	if health <= 0:
		global.p_is_alive = false
	if global.p_is_alive == false:
		HitArea.stop()
		anim.stop()
		anim.play("Death")
		self.queue_free()
		print("player has been slain")
#-------------------------------------------------------------------------------






#----------PLAYER_GIVING_DAMAGE-------------------------------------------------
func _on_pl_attack_cooldown_timeout():
	global.p_attack_cooldown = true
func _on_hit_area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.has_method("eHurtBox"):
		global.p_target_inattack_range = true
		print("pHitArea  in eHurtBox") #CHECK
func player_attack():
	if global.p_target_inattack_range == true and global.p_attack_cooldown == true:
		if Input.is_action_just_pressed("attack"):
			HitArea.play("Attack"+lookingDirection)
			global.p_is_attacking_target = true
			print("player has attacked")
			global.p_attack_cooldown = false
			$pl_attack_cooldown.start()
	if global.p_target_inattack_range == false: # ATTACKING TO EMPTINESS 
		if Input.is_action_just_pressed("attack") and global.p_attack_cooldown == true:
			HitArea.play("Attack"+lookingDirection)
			print("player empty attack")
			global.p_attack_cooldown = false
			$pl_attack_cooldown.start()
func _on_hit_area_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if global.e_is_alive == true:
		if area.has_method("eHurtBox"):
			global.p_target_inattack_range = false
	else:
		global.p_target_inattack_range = false
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
func hand():
	if global.p_cur_weapon == "asd1": # ASD1 IS A WEAPON NAME, CHOSABLE 
		global.p_attack_power += 0.5



