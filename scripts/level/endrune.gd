extends StaticBody2D


func _on_EndRuneTrigger_body_exited(body):
	if body.masktotal == 4:
		set_collision_mask_bit (0, false)
		$AnimationPlayer.play("dissolve")
		$"../EndRuneTrigger".set_collision_mask_bit(0, false)
		for enemy in $"../../EnemySpawner/YSort".get_children():
			enemy.die(0)
