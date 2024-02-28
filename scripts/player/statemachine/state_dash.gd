extends State


# public / private variables
var timer = 0.0
var direction


func enter():
	if target.dash_charges <= 0:
		if Retry.sfx_on:
			$"../../Sounds/DashErrorSound".play()
		exit()
	else:
		$"../../DashVFX".animation = "dash"
		timer = target.dash_time
		target.dash()
		if target.get_sprite_direction():
			direction = Vector2(-1,0)
		else:
			direction = Vector2(1,0)


func exit():
	target.invuln = false
	timer = 0.0
	target.set_enemy_collision(false)
	$"../../DashVFX".animation = "default"
	$"../../AnimationPlayer".play("RESET")
	state_machine.transition_to("Walk")


func update(delta):
	if timer >= 0:
		timer -= delta
		target.push(direction, "dash")
	else:
		exit()


func _on_BodyArea_body_entered(body): # obstacle collision
	if state_machine.state == self && body.has_method("take_damage"):
		body.take_damage(target.dash_damage, target.get_global_position(), target.get_state())


func _on_BodyArea_area_entered(area): # enemy collision
	if state_machine.state == self && area.has_method("take_damage"):
		area.take_damage(target.dash_damage, target.get_global_position(), target.get_state())
		# small knockback to back off the hit target
		movement_direction = target.move_and_slide(direction * -1000)
		$"../../Camera2D".start_shaking(0.1)
		exit()
