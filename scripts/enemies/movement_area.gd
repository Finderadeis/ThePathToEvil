extends Area2D
# delegates ground damage signal to enemy script

# signals
signal Movement_got_hit(main_attack_damage)


# public / private functions
func take_damage(dmg, source):
	emit_signal("Movement_got_hit", dmg, source)
