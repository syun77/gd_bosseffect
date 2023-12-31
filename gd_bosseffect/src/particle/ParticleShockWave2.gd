extends Particle

var _step = 0

func _update(delta: float) -> void:
	move(delta)
	
	var sc = 0.25
	var sx = 1.0
	var sy = 1.0
	match _step:
		0:
			material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			var rate = _timer / 2.0
			sc += 0.3 * rate
			if rate >= 1:
				_timer = 0
				_life = 1.0
				_step += 1
				material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
		1:
			sc += 0.3
			if _timer < 0.1:
				var rate = Ease.expo_out(_timer / 0.1)
				sx -= 0.2 * rate
				sy += 0.3 * rate
			else:
				var rate = (_timer-0.1) / 0.9
				sx = (sx - 0.2) * 10 * Ease.expo_out(rate)
				sy = (sy + 0.3) * (1 - Ease.expo_out(rate*1.5))
	
	scale = Vector2(sx*sc, sy*sc)
