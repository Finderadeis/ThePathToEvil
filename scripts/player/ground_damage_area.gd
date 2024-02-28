extends Area2D
# delegates ground damage signal to enemy script


signal got_hit(damage, source)

func take_damage(dmg, source):
	emit_signal("got_hit", dmg, source)
