extends KinematicBody2D
# Enemy Script handling movement, target detection and attacks


# signals
signal dying(ult_perc, pos)
signal died(node)
signal ult_enemy_died


# enums
enum EnemyState {
	FREE_MOVE,
	TARGET_SPOTTED,
	ATTACK,
	KNOCKBACK,
	DYING,
	STUNNED,
	CIRCLE_TARGET,
}


# export variables, variable type and value are optional
export (bool) var is_template
export (int) var type_id
export (SpriteFrames) var anim_frames
export (Material) var dissolve_mat
export (float) var scale_factor
export (float) var speed
export (float) var max_health
export (float) var knockback_time
export (float) var knockback_strength
export (int) var main_attack_damage
export (float) var main_attack_cooldown
export (float) var stun_time
export (int) var ult_percentage
export (Color) var original_color

export (float) var start_spawnrate
export (int) var start_count
export (int) var max_count
export (float) var max_count_increase
export (float) var start_spawn_chance
export (float) var spawn_chance_increase


# public / private variables
var movement_direction = Vector2(0,0)
var state
var health
var target
var target_in_range = false
var knockback_source
var last_player_position = Vector2(0.0,0.0)
var tmp_ult_perc

var timer_main_attack = 0.0
var timer_knockback = 0.0
var timer_stun = 0.0
var distance_to_target
var ally_position
var circle_direction

var can_spawn = false
var spawn_range = Vector2(0.0,0.0)
var current_max_count
var current_count
var current_spawn_chance
var invuln = false
var base_scale


# Godot callback methods
func _ready():
	state = EnemyState.FREE_MOVE
	health = max_health
	$Sprite.frames = anim_frames#shader_param/sprite
	$DissolveParticles.process_material = dissolve_mat
	$DissolveParticles.emitting = false
	base_scale = Vector2(scale_factor,scale_factor)


func _physics_process(delta):
	if is_template:
		return

	update_timers(delta)
	if state != EnemyState.STUNNED:
		$StunnedSprite.hide()

	match state:
		EnemyState.FREE_MOVE:
			$Sprite.animation = "walk"
			$Sprite.playing = true
			if last_player_position.x >= get_global_position().x:
				movement_direction = Vector2(1,0)
			else:
				movement_direction = Vector2(-1,0)
			movement_direction = move_and_slide(movement_direction * speed)
		EnemyState.TARGET_SPOTTED:
			$Sprite.animation = "walk"
			$Sprite.playing = true
			if target.is_alive():
				movement_direction = evaluate_direction()
				movement_direction = move_and_slide(movement_direction * speed)
			else:
				state = EnemyState.FREE_MOVE
		EnemyState.CIRCLE_TARGET:
			$Sprite.animation = "walk"
			$Sprite.playing = true
			if target.is_alive():
				movement_direction = evaluate_circling_direction()
				movement_direction = move_and_slide(movement_direction * speed)
		EnemyState.KNOCKBACK:
			if timer_knockback > 0.0:
				if knockback_source.x >= get_global_position().x:
					movement_direction = Vector2(-1,0)
				else:
					movement_direction = Vector2(1,0)
				movement_direction = move_and_slide(movement_direction * knockback_strength)
			else:
				$Sprite.modulate = original_color
				state = EnemyState.TARGET_SPOTTED
		EnemyState.ATTACK:
			if target.is_alive():
				try_attack()
			else:
				state = EnemyState.FREE_MOVE
		EnemyState.STUNNED:
			if timer_stun > 0.0:
				pass
			else:
				$Sprite.modulate = original_color
				if target_in_range:
					state = EnemyState.ATTACK
				else:
					state = EnemyState.TARGET_SPOTTED
	updateDepthScale()


# public / private functions
func update_timers(delta):
	if timer_knockback > 0.0:
		timer_knockback -= delta
	else:
		timer_knockback = 0.0

	if timer_main_attack > 0.0:
		timer_main_attack -= delta
	else:
		timer_main_attack = 0.0

	if timer_stun >= 0.0:
		timer_stun -= delta
	else:
		timer_stun = 0.0


func updateDepthScale():
	scale = base_scale * (1 + (position.y) / 1400)


func evaluate_direction():
	var target_position = target.get_global_position()
	var direction = Vector2(0,0)

	if target_position.x > get_global_position().x:
		direction = get_global_position().linear_interpolate(target_position, speed)
		$Sprite.flip_h = true
	else:
		direction = get_global_position().linear_interpolate(target_position, speed)
		$Sprite.flip_h = false
		
	return direction.normalized()


func evaluate_circling_direction():
	var target_position = target.get_global_position()
	var direction = Vector2(0,0)
	var global_pos = get_global_position()
	distance_to_target = global_pos - target.get_position()

	direction = global_pos.linear_interpolate(Vector2(target_position.x, target_position.y-(distance_to_target.x*circle_direction)), speed)

	return direction.normalized()


func try_attack():
	if timer_main_attack == 0.0:
		if  $Sprite.flip_h == false:
			$AnimationPlayer.play("AttackLeft")
			timer_main_attack = main_attack_cooldown
		elif $Sprite.flip_h == true:
			$AnimationPlayer.play("AttackRight")
			timer_main_attack = main_attack_cooldown
		if Retry.sfx_on:
			$Sounds/AttackSound.play()


func take_damage(amount, source_position, source_type):
	if invuln:
		return
	
	$AnimationPlayer.play("ouch")

	match source_type:
		"Attack", "HeavyAttack":
			health -= amount
			if health <= 0:
				die(ult_percentage)
			else:
				timer_knockback = knockback_time
				knockback_source = source_position
				state = EnemyState.KNOCKBACK
				$Sprite.modulate = Color(0.21, 0.38, 0.63)
		"Dash":
			knockback_source = source_position
			get_stunned()
	invuln = true
	yield(get_tree().create_timer(0.2), "timeout")
	invuln = false


func get_stunned():
	timer_stun = stun_time
	state = EnemyState.STUNNED
	$Sprite.modulate = Color(0.16, 0.16, 0.16)
	if Retry.sfx_on:
		$Sounds/StunnedSound.play()
	$StunnedSprite.show()


func die(ult_perc):
	if state != EnemyState.DYING:
		if ult_perc == 0:
			$ExplodingParticles.emitting = true
		tmp_ult_perc = ult_perc
		state = EnemyState.DYING
		emit_signal("dying", tmp_ult_perc, get_global_position())
		$DissolveParticles.scale = base_scale * (1 + (position.y) / 1400)
		$AnimationPlayer.play("Die_alt")
		if Retry.sfx_on:
			$Sounds/DeathSound.play()
	if self.name == "UltEnemy":
		emit_signal("ult_enemy_died")


# signal handling
func _on_PlayerDetectionRange_body_entered(body):
	if state != EnemyState.DYING && state != EnemyState.KNOCKBACK && state != EnemyState.STUNNED:
		if body.has_method("is_alive"):
			if body.is_alive():
				target = body
				state = EnemyState.TARGET_SPOTTED


func _on_AttackRange_area_entered(_area):
	target_in_range = true
	if state != EnemyState.DYING && state != EnemyState.KNOCKBACK && state != EnemyState.STUNNED:
		state = EnemyState.ATTACK


func _on_AttackRange_area_exited(_area):
	target_in_range = false
	if state != EnemyState.DYING && state != EnemyState.KNOCKBACK && state != EnemyState.STUNNED:
		state = EnemyState.TARGET_SPOTTED


func _on_Fist_area_entered(area):
	$AttackArea/AttackCollision.disabled = true
	if state != EnemyState.DYING && state != EnemyState.KNOCKBACK && state != EnemyState.STUNNED:
		area.take_damage(main_attack_damage, get_global_position())


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Die":
		emit_signal("died", self)
	if anim_name == "AttackLeft" || anim_name == "AttackRight":
		if target_in_range:
			try_attack()
		else:
			state = EnemyState.TARGET_SPOTTED


func _on_AllyDetectionRange_area_entered(area):
	if state == EnemyState.TARGET_SPOTTED:
	# check enemypos - playerpos for both enemies and let the on with bigger abs result move away
		ally_position = area.get_global_position()
		state = EnemyState.CIRCLE_TARGET


func _on_AllyDetectionRange_area_exited(_area):
	if state == EnemyState.CIRCLE_TARGET:
		state = EnemyState.TARGET_SPOTTED


func _on_BodyArea_got_hit(damage, source_position, source_type):
	take_damage(damage, source_position, source_type)
