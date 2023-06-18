extends Node2D

# ==========================================
# 敵.
# ==========================================
class_name Enemy

# ------------------------------------------
# preload.
# ------------------------------------------
var PARTICLE_EXPLOSION = preload("res://src/particle/ParticleExplosion.tscn")

# ------------------------------------------
# consts.
# ------------------------------------------
const SIZE = 256 * 0.75 / 2
enum eType {
	ANIM_PATTERN,
	ANIM_PATTERN2,
}

# ------------------------------------------
# onready.
# ------------------------------------------
@onready var _spr = $Sprite

# ------------------------------------------
# vars.
# ------------------------------------------
var _id = eType.ANIM_PATTERN
var _cnt = 0
var _timer = 0.0
var _max_timer = 3.0
var _velocity = Vector2()

# ------------------------------------------
# function.
# ------------------------------------------
func set_type(id:eType) -> void:
	_id = id
	var funcname = "_init_" + eType.keys()[_id]
	if has_method(funcname):
		# 初期化関数があれば呼び出し.
		call(funcname)
	
## 速度を設定.
func set_velocity(deg:float, spd:float) -> void:
	var rad = deg_to_rad(deg)
	_velocity.x = spd * cos(rad)
	_velocity.y = spd * -sin(rad)
	
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

func _move(delta:float) -> void:
	call("_move_" + eType.keys()[_id], delta)
	
func _x_move_and_clip(delta:float) -> bool:
	position.x += _velocity.x * delta
	if position.x < 480 + SIZE:
		position.x = 480 + SIZE
		return true
	if position.x > 1080 - SIZE:
		position.x = 1080 - SIZE
		return true
	return false
func _y_move_and_clip(delta:float) -> bool:
	position.y += _velocity.y * delta;
	if position.y < SIZE:
		position.y = SIZE
		return true
	if position.y > 640 - SIZE:
		position.y = 640 - SIZE
		return true
	return false
	

func _physics_process(delta: float) -> void:
	_cnt += 1
	_timer += delta
	
	# 移動.
	_move(delta)
	
	if _timer >= _max_timer:
		destroy()
		queue_free()

## オーソドックスなパターン.
func _move_ANIM_PATTERN(delta:float) -> void:
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

## 画面内を動き回るパターン.
func _init_ANIM_PATTERN2() -> void:
	var spd = 1000;
	var deg = randf_range(0, 360)
	set_velocity(deg, spd)
	_max_timer = 2.0
	
func _move_ANIM_PATTERN2(delta:float) -> void:
	if _x_move_and_clip(delta):
		_velocity.x *= -1
	if _y_move_and_clip(delta):
		_velocity.y *= -1
	rotation_degrees += 1000 * delta

	if _cnt > 10:
		var deg = randf_range(0, 360)
		var spd = randf_range(100, 300)
		var sc = randf_range(0.8, 1.2)
		var ofs = Vector2(randf_range(-64, 64), randf_range(-64, 64))
		_add_particle(deg, spd, sc, ofs)
		_cnt -= 10
	_cnt += randi_range(0, 2)

