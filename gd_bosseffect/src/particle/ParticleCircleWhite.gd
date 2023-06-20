extends Particle

func _update(delta: float) -> void:
	move(delta)

	queue_redraw()
	
func _draw() -> void:
	var rate = get_time_rate()
	var radius = 1024 * Ease.expo_out(rate)
	var alpha = 1
	if rate > 0.6:
		alpha *= 1 - ((rate - 0.6) / 0.4)
	var c = color
	c.a = alpha
	draw_circle(Vector2.ZERO, radius, c)
