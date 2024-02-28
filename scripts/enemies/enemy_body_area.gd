extends Area2D
# delegates body damage signal to enemy script


# signals
signal got_hit(damage, source_position, source_type)


# public / private functions
func take_damage(dmg, source, type):
	emit_signal("got_hit", dmg, source, type)

func get_vuln_status():
	return $"..".invuln
