extends State

var fully_charged
var scale_factor = 0.01

func enter():
	fully_charged = false
	$ChargeTimer.start()
	if Retry.sfx_on:
		$"../../Sounds/AttackChargeSound".play()
	$"../../Sprite".playing = false
#	$"../../AttackChargeVFX".animation = "charging"
#	$"../../AttackChargeVFX".scale = Vector2(0.0,0.0)
#	$"../../AttackChargeVFX".modulate.a = 0.0
#	$"../../AttackChargeParticles".visible = true
#	$"../../AttackChargeParticles".scale = Vector2(0.0,0.0)
#	$"../../AttackChargeParticles".modulate.a = 0.0
	$"../../ChargeParticlePlayer".play("Charging")


func update(delta):
	if Input.is_action_pressed("left") || Input.is_action_pressed("right"):
		if get_movement_direction().x == 1:
			target.flip_sprite(false)
		else:
			target.flip_sprite(true)
	if Input.is_action_just_released("main_attack"):
		$"../../ChargeParticlePlayer".play("RESET")
		$"../../Sprite".playing = true
		$ChargeTimer.stop()
#		$"../../ChargeParticles".emitting = false
#		$"../../AttackChargeVFX".modulate = Color(1.0,1.0,1.0)
#		$"../../AttackChargeParticles".modulate = Color(1.0,1.0,1.0)
		$"../../Sounds/AttackChargeSound".stop()
#		$"../../AttackChargeVFX".animation = "default"
#		$"../../AttackChargeParticles".visible = false
		if fully_charged:
			state_machine.transition_to("HeavyAttack")
			pass
		else:
			state_machine.transition_to("Attack")
	else:
		if !fully_charged:
#			$"../../AttackChargeVFX".scale += Vector2(scale_factor,scale_factor)
#			$"../../AttackChargeVFX".modulate.a += scale_factor
#			$"../../AttackChargeParticles".scale += Vector2(scale_factor,scale_factor)
#			$"../../AttackChargeParticles".modulate.a += scale_factor
			pass
		else:
#			$"../../AttackChargeVFX".scale = Vector2(1.0,1.0)
#			$"../../AttackChargeVFX".modulate.a = 1.0
#			$"../../AttackChargeParticles".scale = Vector2(0.7,0.7)
#			$"../../AttackChargeParticles".modulate.a = 1.0
			pass


func _on_ChargeTimer_timeout():
	fully_charged = true
#	$"../../ChargeParticles".emitting = true
	$"../../ChargeParticlePlayer".play("Charged")
#	$"../../AttackChargeVFX".modulate = Color(2.9,2.9,2.9)
#	$"../../AttackChargeParticles".modulate = Color(2.9,2.9,2.9)
