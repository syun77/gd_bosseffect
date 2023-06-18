extends Particle

# パターンアニメ数.
const MAX_ANIM = 38

func _physics_process(delta: float) -> void:
	move(delta)
	var rate = get_time_rate()
	frame = int(MAX_ANIM * rate)
