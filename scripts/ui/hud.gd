extends CanvasLayer

var playernode
var shake_strength = 0.0

export var shake_falloff = 0.5
export var max_shake_offset = Vector2(100, 75)
export var max_shake_roll = 0.1

signal allmask

func _ready():
#	$UltSprite.modulate.a = 0.3
	if Retry.active == false:
		$UltSprite.hide()


func _process(delta):
	if shake_strength > 0.0:
		shake_strength = max(shake_strength - shake_falloff * delta, 0)
		shake()

func start_shaking(amount):
	shake_strength = min(shake_strength + amount, 1.0)


func shake():
	var amount = pow(shake_strength, 2)
	$HealthSprite.rotation = max_shake_roll * amount * rand_range(-1, 1)
	$HealthSprite.offset.x = max_shake_offset.x * amount * rand_range(-1, 1)
	$HealthSprite.offset.y = max_shake_offset.y * amount * rand_range(-1, 1)



func _on_Player_died():
	$UI_Screens/DeathScreen.show()
	if Retry.sfx_on && Retry.music_on:
		$HealthAlertPlayer.play("Death")
	elif Retry.sfx_on && Retry.music_on == false:
		$HealthAlertPlayer.play("DeathNoMusic")
	elif Retry.music_on && Retry.sfx_on == false:
		$HealthAlertPlayer.play("DeathNoFX")
	get_tree().paused = true


func _on_Player_health_changed(_new_health):
	if playernode.health >= 50:
		$HealthSprite.frame = 5
	elif playernode.health >= 40:
		$HealthSprite.frame = 4
		start_shaking(0.2)
	elif playernode.health >= 30:
		$HealthSprite.frame = 3
		start_shaking(0.4)
	elif playernode.health >= 20:
		$HealthSprite.frame = 2
		start_shaking(0.5)
		alert("Low")
	elif playernode.health >= 10:
		$HealthSprite.frame = 1
		start_shaking(0.6)
		alert("VeryLow")
	elif playernode.health <= 0:
		start_shaking(0.7)
		$HealthSprite.frame = 0

func _on_Player_dash_charges_changed(_new_charges):
	glow($DashSprite)
	if playernode.dash_charges >= 3:
		$DashSprite.frame = 3
	elif playernode.dash_charges == 2:
		$DashSprite.frame = 2
	elif playernode.dash_charges == 1:
		$DashSprite.frame = 1
	elif playernode.dash_charges == 0:
		$DashSprite.frame = 0

func _on_Player_ult_changed(_new_ult):
#	$UltSprite.scale = Vector2(1.09,1.09)
#	yield(get_tree().create_timer(0.5), "timeout")
#	$UltSprite.scale = Vector2(1.0,1.0)
	glow($UltSprite)
	if playernode.ult_charge >= 0:
		$UltSprite.frame = 0
#		if playernode.ult_charge >= 30:
#			$UltSprite.modulate.a = playernode.ult_charge/100.0
	if playernode.ult_charge >= 50:
		$UltSprite.frame = 1
#		$UltSprite.modulate.a = playernode.ult_charge/100.0
	if playernode.ult_charge >= playernode.ult_max_charge:
		$UltSprite.frame = 2
		$UltSprite.visible = true


func _on_Player_health_gained():
	glow($HealthSprite)
	$HealthAlertSFX.stop()
	if playernode.health >= 50:
		$HealthSprite.frame = 5
	elif playernode.health >= 40:
		$HealthSprite.frame = 4
		$HealthAlertPlayer.play("RESET")
	elif playernode.health >= 30:
		$HealthSprite.frame = 3
		$HealthAlertPlayer.play("RESET")
	elif playernode.health >= 20:
		$HealthSprite.frame = 2
	elif playernode.health >= 10:
		$HealthSprite.frame = 1
	elif playernode.health <= 0:
		$HealthSprite.frame = 0
	
func glow(sprite):
	if sprite == $HealthSprite:
		sprite.modulate = Color(1.7,1.7,1.7)
		sprite.scale = Vector2(1.08,1.08)
	if sprite == $DashSprite:
		sprite.modulate = Color(1.6,1.6,1.6)
		sprite.scale = Vector2(1.05,1.05)
	if sprite == $UltSprite:
		sprite.scale = Vector2(1.09,1.09)
	yield(get_tree().create_timer(0.5), "timeout")
	sprite.modulate = Color(1.0,1.0,1.0)
	sprite.scale = Vector2(1.0,1.0)

func alert(anim_name):
	if playernode.health >= 20:
		$HealthAlertPlayer.play(anim_name)
	elif playernode.health <=20:
		$HealthAlertPlayer.play(anim_name)
		if Retry.sfx_on:
			$HealthAlertSFX.play()
	else:
		$HealthAlertPlayer.play("RESET")
		$HealthAlertSFX.stop()

func _on_Player_mask_collected(masktotal):
	if masktotal >= 4:
		$MaskSprite.frame = 4
		emit_signal("allmask")
	elif masktotal >= 3:
		$MaskSprite.frame = 3
	elif masktotal >= 2:
		$MaskSprite.frame = 2
	elif masktotal >= 1:
		$MaskSprite.frame = 1
	else:
		$MaskSprite.frame = 0

func _on_EndRuneTrigger_body_exited(body):
	$MaskSprite.hide()
	$HealthSprite.hide()
	$DashSprite.hide()
	$UltSprite.hide()
	$HealthAlertPlayer.play("RESET")
	$HealthAlertSFX.stop()
