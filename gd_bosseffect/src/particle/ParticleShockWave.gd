extends Particle

func _update(delta: float) -> void:
	move(delta)

	queue_redraw()

func _draw() -> void:
	var rate = get_time_rate()
	var alpha = 0.7
	if rate > 0.9:
		alpha *= (1 - rate) / 0.1
	var w = 2048 * Ease.expo_out(rate)
	var h = 2048
	var x = -w/2
	var y = -h/2
	var rect = Rect2(x, y, w, h)
	var c = color
	c.a = alpha
	draw_rect(rect, c)
