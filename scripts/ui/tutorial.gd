extends Control

# handles behaviour of the tutorial animations
var playernode

var attack_done
var attack_in
var dash_done
var dash_in
var heavy_done
var heavy_in
var ult_done
var ult_in
var tutorial_done


func _physics_process(_delta):
	if Retry.active == true:
		pass
	elif attack_in != true:
		pass
	elif tutorial_done == true:
		pass
	else:
		play_tutorial()


func _on_TutorialTrigger_body_entered(_body):
	if  Retry.active != true:
		$AnimationPlayer.play("TutorialStart")
	else:
		pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "TutorialStart":
		attack_in = true
	if anim_name == "AttackDone":
		$AnimationPlayer.play("DashStart")
	if anim_name == "DashStart":
		dash_in = true
	if anim_name == "DashDone":
		$AnimationPlayer.play("HeavyStart")
	if anim_name == "HeavyStart":
		heavy_in = true
	if anim_name == "HeavyDone":
		$"../../YSort/EnemySpawner".spawn_tutorial_enemy(1)
	if anim_name == "UltStart":
		ult_in = true
	
func play_tutorial():
	if $AnimationPlayer.is_playing() == false:
		if attack_in == true:
			if Input.is_action_just_pressed("main_attack")  && attack_done != true:
				$AnimationPlayer.play("AttackDone")
				attack_done = true
		if dash_in == true:
			if Input.is_action_just_pressed("dash") && dash_done != true:
				$AnimationPlayer.play("DashDone")
				dash_done = true
		if heavy_in == true:
			if playernode.fully_charged == true && heavy_done != true:
				$AnimationPlayer.play("HeavyDone")
				heavy_done = true
		if $"../../YSort/EnemySpawner".ult_enemy_dead == true && ult_in != true:
			$AnimationPlayer.play("UltStart")
		if ult_in == true:
			if Input.is_action_just_pressed("ultimate") && ult_done != true:
				$AnimationPlayer.play("UltDone")
				ult_done = true
				tutorial_done = true
