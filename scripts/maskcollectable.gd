extends Area2D


func _on_MaskCollectableObject_area_entered(area):
	$AnimationPlayer.play("fade_out")
	if area.has_method("mask_counter"):
		area.mask_counter()
