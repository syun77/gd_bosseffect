extends Particle

func _update(delta: float) -> void:
	move(delta)

	var rate = get_time_rate()
	var alpha = 0.5
	if rate > 0.8:
		alpha *= 1 - ((rate - 0.8) / 0.2)
	var sx = 0.5 * (1 - Ease.expo_out(rate))
	scale.x = sx
	modulate = color
	modulate.a = alpha
