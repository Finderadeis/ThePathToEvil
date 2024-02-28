extends Area2D

# export variables, variable type and value are optional
export (float) var health_amount
var collected = false

var notcollected = false

# signal handling
func _on_CollectibleObjects_area_entered(area):
	if area.has_method("refill_health") && !collected:
		if area.health_full() == false:
			collected = true
			area.refill_health(health_amount)
			$AnimationPlayer.play("fade_out")
		elif area.health_full() == true:
			if notcollected == false:
				return
			else:
				$AnimationPlayer.play("NotCollected")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "life_spawn":
		notcollected = true


func _on_AnimationPlayer_ready():
	$AnimationPlayer.play("life_spawn")
