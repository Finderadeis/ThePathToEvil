extends KinematicBody2D
# Player Script handling export variables, getters and signals


# signals
signal moved(pos)
signal died
signal health_changed(new_health)
signal health_gained
signal dash_charges_changed(new_charges)
signal ult_changed(new_ult)

signal mask_collected(newmasktotal)


# export variables, variable type and value are optional
export (float) var speed
export (int) var max_health
export (float) var knockback_time
export (float) var knockback_strength
export (float) var main_attack_damage
export (float) var charged_attack_damage
export (float) var charged_attack_shake
export (float) var dash_damage
export (int) var max_dash_charges
export (float) var dash_recharge_time
export (float) var dash_time
export (float) var dash_speed
export (float) var ult_max_charge
export (float) var ult_shake
export (float) var ult_spawn_pause
export (PackedScene) var enemy_soul_prticles
export (bool) var invuln = false


# public / private variables
var health
var ult_charge = 0.0
var knockback_source = Vector2(0,0)
var dash_charges
var dash_recharge_timer = 0.0
var fully_charged = false
var rng = RandomNumberGenerator.new()

var masktotal = 0
var hit_enemy_buffer = Array()
var enemy_hit = false

# onready variables
onready var state_machine = $StateMachine


# Godot callback methods
func _ready():
	health = max_health
	dash_charges = max_dash_charges
	rng.randomize()


func _physics_process(delta):
	updateDepthScale()
	if dash_recharge_timer > 0.0:
		dash_recharge_timer -= delta
	else:
		dash_recharge_timer = dash_recharge_time
		if dash_charges >= max_dash_charges:
			dash_charges = max_dash_charges
		else:
			dash_charges += 1
			emit_signal("dash_charges_changed", dash_charges)

# public / private functions
func is_alive():
	return health > 0


func get_state():
	return state_machine.state.name


func flip_sprite(b_flip):
	$Sprite.flip_h = b_flip
	$DashVFX.flip_h = b_flip
	if b_flip:
		$UltHint.position = Vector2(-43.0, -176.0)
#		$AttackChargeVFX.rotation_degrees = -68.8
#		$AttackChargeVFX.position = Vector2(86.0, -113)
		$Particles.position = Vector2(95.0, -118.0)
		$Light2D.position = Vector2(97.0, -19.0)
	else:
		$UltHint.position = Vector2(23.0, -176.0)
#		$AttackChargeVFX.position = Vector2(-96.0, -113)
#		$AttackChargeVFX.rotation_degrees = 18.8
		$Particles.position = Vector2(-92.0, -118.0)
		$Light2D.position = Vector2(-60.0, -4.0)
	for soul in $EnemySoulParticles.get_children():
		soul.flip = b_flip


func get_sprite_direction():
	return $Sprite.flip_h


func updateDepthScale():
	scale = Vector2(1,1) * (1 + (position.y - 750) / 1400)


func set_obstacle_collision(val):
	set_collision_mask_bit (21, val)


func set_enemy_collision(val):
	set_collision_mask_bit (15, val)


func take_damage(amount, source_position):
	if get_state() == "Dash" || get_state() == "Knockback" || invuln:
		return
#	$AttackChargeVFX.animation = "default"
#	$AttackChargeParticles.visible = false
	$ChargeParticlePlayer.play("RESET")
	health -= amount
	emit_signal("health_changed", health)
	if health <= 0:
		state_machine.transition_to("Dying")
	else:
		knockback_source = source_position
		state_machine.transition_to("Knockback")
		invuln = true

func start_attack():
	$AnimationPlayer.play("StartAttack")
	if Retry.sfx_on:
		$Sounds/BasicAttackSound.play()


func attack():
	if $Sprite.flip_h:
		$AnimationPlayer.play("PunchLeftCut")
	else:
		$AnimationPlayer.play("PunchRightCut")
	if Retry.sfx_on:
		$Sounds/BasicAttackSound.play()


func die():
	$AnimationPlayer.play("Die")
	if Retry.sfx_on:
		$Sounds/DeathSound.play()


func knockback():
	$AnimationPlayer.play("Hurt")
	if Retry.sfx_on:
		$Sounds/HurtSound.play()
	$Sprite.playing = true


func move(direction):
	move_and_slide(direction * speed)
	emit_signal("moved", get_global_position())
	$Sprite.modulate = Color(1,1,1)


func push(direction, type):
	match type:
		"dash":
			move_and_slide(direction * dash_speed)
		"knockback":
			move_and_slide(direction * knockback_strength)
	emit_signal("moved", get_global_position())


func dash():
	set_enemy_collision(true)
	if Retry.sfx_on:
		$Sounds/DashSound.play()
	$AnimationPlayer.play("Dash")
	dash_recharge_timer = dash_recharge_time
	dash_charges -= 1
	if dash_charges < 0:
		dash_charges = 0
	emit_signal("dash_charges_changed", dash_charges)


func perform_ultimate():
	$Camera2D.start_shaking(ult_shake)
	if Retry.sfx_on:
		$Sounds/UltimateSound.play()
	$UltParticles.emitting = true
	for enemy in $"../EnemySpawner/YSort".get_children():
		enemy.die(0)
	$"../EnemySpawner".pause_spawning(ult_spawn_pause)
	ult_charge = 0
	$UltHint.amount = 1
	emit_signal("ult_changed", ult_charge)


# signal handling
func _on_Fist_body_entered(body): #grass hit
	if body.has_method("take_damage"):
		if get_state() == "HeavyAttack":
			body.take_damage(charged_attack_damage, get_global_position(), get_state())
		else:
			body.take_damage(main_attack_damage, get_global_position(), get_state())


func _on_Fist_area_entered(area): #enemy hit
	if area.has_method("take_damage"):
		$AttackArea/AttackCollision.disabled = true
		
#		if Retry.sfx_on && !area.get_vuln_status():
#			$Sounds/BasicHitSound.play()
#		if get_state() == "HeavyAttack":
#			area.take_damage(charged_attack_damage, get_global_position(), get_state())
#			$Camera2D.start_shaking(charged_attack_shake)
#		else:
#			area.take_damage(main_attack_damage, get_global_position(), get_state())
		hit_enemy_buffer.append(area)


func damage_hit_enemy():
	if hit_enemy_buffer.empty() || enemy_hit:
		return
	if Retry.sfx_on && !hit_enemy_buffer[0].get_vuln_status():
		$Sounds/BasicHitSound.play()
	if get_state() == "HeavyAttack":
		hit_enemy_buffer[0].take_damage(charged_attack_damage, get_global_position(), get_state())
		$Camera2D.start_shaking(charged_attack_shake)
	else:
		hit_enemy_buffer[0].take_damage(main_attack_damage, get_global_position(), get_state())
	if get_state() == "Attack":
		enemy_hit = true
	hit_enemy_buffer.clear()


func clear_enemy_buffer():
	enemy_hit = false
	hit_enemy_buffer.clear()

func _on_BodyArea_got_hit(damage, source_position):
	take_damage(damage, source_position)


func _on_EnemySpawner_enemy_destroyed(ult_perc, pos):
	if ult_perc == 0 && get_state() == "Ultimate":
		state_machine.state.exit()
	else:
		if ult_charge < ult_max_charge:
			ult_charge += ult_perc
			$UltHint.amount = ult_charge*2
		if ult_charge >= ult_max_charge:
			$UltHint.amount = ult_charge*10
	emit_signal("ult_changed", ult_charge)
	spawn_enemy_soul(pos-get_global_position())


func spawn_enemy_soul(distance):
	var new_soul = enemy_soul_prticles.instance()
	new_soul.position = distance
	$EnemySoulParticles.add_child(new_soul)
	new_soul.container_position = $EnemySoulParticles.position


func _on_DeathSound_finished():
	state_machine.state.exit()
	emit_signal("died")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"StartAttack":
			if Input.is_action_pressed("main_attack"):
				state_machine.transition_to("AttackCharge")
			else:
				state_machine.transition_to("Attack")
		"PunchLeftCut" , "PunchRightCut":
			state_machine.state.exit()
		"Die":
			if !Retry.sfx_on:
				state_machine.state.exit()
				emit_signal("died")


func _on_GroundDamageArea_got_hit(damage, source):
	take_damage(damage, source)


func _on_BodyArea_gained_health(amount):
	health += amount
	if health > max_health:
		health = max_health
	emit_signal("health_gained")


func _on_ChargeTimer_timeout():
	fully_charged = true


#mask hud counter
func _on_BodyArea_mask_collected():
	masktotal += 1
	emit_signal("mask_collected", masktotal)


func _on_WinTrigger_body_entered(body):
	for soul in $EnemySoulParticles.get_children():
		soul.game_end_reached()
