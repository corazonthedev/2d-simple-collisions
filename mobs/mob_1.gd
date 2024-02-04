extends CharacterBody2D

#----ANIMATIONS-----------------------------------------------------------------
@onready var HitArea = $HitArea/AnimationAttack
@onready var anim = $AnimationPlayer
#----HEALTH---------------------------------------------------------------------
@export var health = 10
#-----UTILITIES-----------------------------------------------------------------
@export var lastPressedMoveKey = ""
@export var lookingDirection = ""
var lastAnim = ""
#------MOVEMENT-----------------------------------------------------------------
@export var speed = 30
#-on_GLOBAL---------------------------------------------------------------------
#-------------------------------------------------------------------------------
#---e_attack_cooldown = true
#---e_target_inattack_range = false 
#---e_is_attacking_target = false
#---e_is_alive = true
#---e_cur_weapon = "dsa1"
#---e_attack_power = 0.85
#-------------------------------------------------------------------------------
#----PATROLLING-----------------------------------------------------------------
var limit = 0.5
@export var startPosition = 0
@export var endPosition = 0
#-----CHASING-------------------------------------------------------------------
@export var chase = false
var is_patrolling = true






func _physics_process(delta):
	moveAnimation()
	enemy_attack()
	hurting()
	dying()
	chasing()
	patrolling()
	move_and_slide()
	
	
	
	
	
	
	
	
	
	
	

func enemy():
	pass

#-----MOVING--------------------------------------------------------------------
func moveAnimation():
	var mDirection 
	if velocity.length() == 0:
		if lastAnim != "Hit" and lastAnim != "Death": #OR AND REPLACEMENT
			if anim.is_playing():
				anim.stop()
	else:
		if velocity.x < 0: mDirection = "Left"
		elif velocity.x > 0: mDirection = "Right"
		elif velocity.y > 0: mDirection = "Down"
		elif velocity.y < 0: mDirection = "Up"
		anim.play(mDirection)
		lastPressedMoveKey = mDirection
		lookingDirection = lastPressedMoveKey
		lastAnim = lastPressedMoveKey
#-------------------------------------------------------------------------------


#------TAKING_DAMAGE------------------------------------------------------------
func hurting():
	if global.p_is_attacking_target == true:
		health -= global.p_attack_power
		print("enemy health = ", health)
		anim.play("Hit") #-----------Hit Down-Up-Right-Left WILL BE ADDED---------------------------
		lastAnim = "Hit"
		global.p_is_attacking_target = false
#-------------------------------------------------------------------------------


#-----DYING---------------------------------------------------------------------
func dying():
	if health <= 0:
		global.e_is_alive = false
	if health <= 0 and global.e_is_alive == false:
		global.p_target_inattack_range = false
		anim.stop()
		anim.play("Death")
		lastAnim = "Death"
		print("enemy has slain")
		self.queue_free()
#-------------------------------------------------------------------------------


#-----GIVING_DAMAGE-------------------------------------------------------------
func _on_enemy_attack_cooldown_timeout():
	global.e_attack_cooldown = true
func _on_hit_area_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.has_method("pHurtBox"):
		global.e_target_inattack_range = true
		print("eHitArea in pHurtBox") #CHECK 
func enemy_attack():
	if global.p_is_alive == false:
		global.e_target_inattack_range = false
	if global.e_target_inattack_range == true and global.e_attack_cooldown == true:
		HitArea.play("Attack"+lookingDirection)
		global.e_attack_cooldown = false
		global.e_is_attacking_target = true
		if global.e_is_attacking_target == true:
			print("enemy has attacked")
		$enemy_attack_cooldown.start()
		
		lastAnim = "Attack"
	if global.e_target_inattack_range == false: #elif to if
		HitArea.stop()
func _on_hit_area_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if global.p_is_alive == true:
		if area.has_method("pHurtBox"):
			global.e_target_inattack_range = false
	else: 
		global.e_target_inattack_range = false
	if global.e_target_inattack_range == false:
			chase = true
#-------------------------------------------------------------------------------

func _ready():
	#---------------------------------------------patrolling
	startPosition = position
	endPosition = startPosition + Vector2(0,50) #down and up
	dying()

#----PATROLLING-----------------------------------------------------------------
func re_patrolling():
	var tempEnd = endPosition
	endPosition = startPosition
	startPosition = tempEnd
func patrolling():
	if is_patrolling == true:
		var moveDirection = (endPosition - position)
		velocity = moveDirection.normalized() * (speed - 10)
		if moveDirection.length() < limit:
			re_patrolling()
#-------------------------------------------------------------------------------


#-----CHASING-------------------------------------------------------------------
func _on_chase_area_body_entered(body):
	if body.name == "player":
		chase = true
		is_patrolling = false
func chasing():
	var player
	if chase == true and global.p_is_alive == true:
		player = get_node("../../Node2D/player")
		var direction = (player.global_position - global_position).normalized() #GLOBAL POSITION
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed
		moveAnimation()
		if global.e_target_inattack_range == true:
			chase = false
			anim.stop()
			velocity.x = 0
			velocity.y = 0
func _on_chase_area_body_exited(body):
	if body.name == "player":
		chase = false
		is_patrolling = true

#-------------------------------------------------------------------------------


#----HAND-----------------------------------------------------------------------
func hand():
	if global.e_cur_weapon == "dsa1":
		global.e_attack_power += 0.25
	
	
	
#-------------------------------------------------------------------------------








