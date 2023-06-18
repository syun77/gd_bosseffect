extends Node2D

var PARTICLE_EXPLOSION = preload("res://src/particle/ParticleExplosion.tscn")

@onready var _spr = $Sprite

var _cnt = 0
var _timer = 0.0
var _max_timer = 3.0

func destroy() -> void:
	for i in range(32):
		var rot = 360 * i / 32.0
		_add_particle(rot, 500, 2.0)

func _add_child(obj) -> void:
	var layer = Common.get_layer("particle")
	layer.add_child(obj)

func _add_particle(deg:float, spd:float, sc:float, ofs:Vector2=Vector2()) -> void:
	var p = PARTICLE_EXPLOSION.instantiate()
	p.position = position + ofs
	p.setup(deg, spd, 1.0, sc)
	_add_child(p)

func _physics_process(delta: float) -> void:
	_cnt += 1
	_timer += delta
	
	# ゆっくり落下.
	position.y += 10 * delta
	
	# 揺らす.
	_spr.offset.x = randf_range(-8, 8)
	
	if _cnt > 10:
		var deg = randf_range(0, 360)
		var spd = randf_range(100, 300)
		var sc = randf_range(0.8, 1.2)
		var ofs = Vector2(randf_range(-64, 64), randf_range(-64, 64))
		_add_particle(deg, spd, sc, ofs)
		_cnt -= 10
	_cnt += randi_range(0, 2)

	if _timer >= _max_timer:
		destroy()
		queue_free()
