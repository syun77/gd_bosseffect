extends Node2D

# ==========================================
# 敵.
# ==========================================
class_name Enemy

# ------------------------------------------
# preload.
# ------------------------------------------
var PARTICLE_EXPLOSION = preload("res://src/particle/ParticleExplosion.tscn")
var PARTICLE_SHOCK_WAVE = preload("res://src/particle/ParticleShockWave.tscn")
var PARTICLE_SHOCK_WAVE2 = preload("res://src/particle/ParticleShockWave2.tscn")
var PARTICLE_RECT = preload("res://src/particle/ParticleRect.tscn")

# ------------------------------------------
# consts.
# ------------------------------------------
const SIZE = 256 * 0.75 / 2
enum eType {
	ANIM_PATTERN,
	ANIM_PATTERN_SLOW,
	ANIM_PATTERN2,
	PARTS,
	SHOCKWAVE_CIRCLE,
	SHOCKWAVE_RECT,
	FLASH,
	WHITE,
}

# ------------------------------------------
# onready.
# ------------------------------------------
@onready var _spr = $Sprite
@onready var _parts1 = $Parts1
@onready var _parts2 = $Parts2

# ------------------------------------------
# vars.
# ------------------------------------------
var _id = eType.ANIM_PATTERN
var _cnt = 0.0
var _step = 0
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
	
	match _id:
		eType.FLASH:
			# 白フラッシュ.
			var p = PARTICLE_SHOCK_WAVE.instantiate()
			p.position = position
			p.setup(0, 0, 1.5)
			_add_child(p)
		eType.SHOCKWAVE_CIRCLE:
			Common.change_bg(Common.eBg.WHITE, 1.0)
		eType.SHOCKWAVE_RECT:
			var p = PARTICLE_RECT.instantiate()
			p.position = position
			p.setup(0, 0, 1.5)
			p.color = Color.RED
			_add_child(p)
		_:
			var spd = 700
			match _id:
				eType.ANIM_PATTERN_SLOW, eType.ANIM_PATTERN2, eType.PARTS, eType.WHITE:
					# スロー再生あり.
					Common.start_slow()
					spd = 1500 # decayの影響を受けるので少し速くする.
			for i in range(32):
				var rot = 360 * i / 32.0
				_add_particle(rot, spd, 2.0)

func _add_child(obj) -> void:
	var layer = Common.get_layer("particle")
	layer.add_child(obj)

func _add_particle(deg:float, spd:float, sc:float, ofs:Vector2=Vector2()) -> void:
	var p = PARTICLE_EXPLOSION.instantiate()
	p.position = position + ofs
	p.setup(deg, spd, 1.0, sc)
	_add_child(p)

func _move(delta:float) -> void:
	var funcname = "_move_" + eType.keys()[_id]
	call(funcname, delta)
	
func _x_move_and_clip(delta:float) -> bool:
	position.x += _velocity.x * delta
	if position.x < 240 + SIZE:
		position.x = 240 + SIZE
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
	delta *= Common.get_slow_rate()
	
	_cnt += 1 * Common.get_slow_rate()
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

## スローあり.
func _init_ANIM_PATTERN_SLOW() -> void:
	_max_timer = 2.0
func _move_ANIM_PATTERN_SLOW(delta:float) -> void:
	_move_ANIM_PATTERN(delta)

## 画面内を動き回るパターン.
func _init_ANIM_PATTERN2() -> void:
	var spd = 2000;
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

## 部位破壊.
func _init_PARTS() -> void:
	# パーツを表示.
	_parts1.visible = true
	_parts2.visible = true
	_max_timer = 1.5

func _move_PARTS(delta:float) -> void:
	# ゆっくり落下.
	position.y += 10 * delta

	_velocity *= 0.9
	position += _velocity * delta
	
	var ofs = Vector2()
	var sc = randf_range(0.8, 1.2)
	match _step:
		0:
			# 揺らす.
			_parts1.offset.x = randf_range(-16, 16)
			ofs += _parts1.position
			sc = randf_range(0.5, 0.8)
			if _timer > 0.8:
				_parts1.visible = false
				_step += 1
				_timer = 0
				set_velocity(180, 500) # 爆発の反動.
				Common.start_slow(0.2, 0.1) # ヒットストップ.
				Common.start_shake(0.2, 1) # 少し揺らす.
				for i in range(32):
					var rot = 360 * i / 32.0
					_add_particle(rot, 350, 0.7, ofs)
		1:
			_cnt = 0
			if _timer > 0.2:
				_step += 1
				_timer = 0
		2:
			# 揺らす.
			_parts2.offset.x = randf_range(-16, 16)
			ofs += _parts2.position
			sc = randf_range(0.5, 0.8)
			if _timer > 0.8:
				_parts2.visible = false
				_step += 1
				_timer = 0
				set_velocity(0, 500) # 爆発の反動.
				Common.start_slow(0.2, 0.1) # ヒットストップ.
				Common.start_shake(0.2, 1) # 少し揺らす.
				for i in range(32):
					var rot = 360 * i / 32.0
					_add_particle(rot, 350, 0.7, ofs)
		3:
			_cnt = 0
			if _timer > 0.2:
				_step += 1
				_timer = 0
		4:
			# 揺らす.
			_spr.offset.x = randf_range(-8, 8)
			ofs += Vector2(randf_range(-64, 64), randf_range(-64, 64))
	if _cnt > 10:
		var deg = randf_range(0, 360)
		var spd = randf_range(100, 300)
		_add_particle(deg, spd, sc, ofs)
		_cnt -= 10
	_cnt += randi_range(0, 2)

## 衝撃波.
func _init_FLASH() -> void:
	_max_timer = 2.0
func _move_FLASH(delta:float) -> void:
	_move_ANIM_PATTERN(delta)

## 背景を白にする.
func _init_WHITE() -> void:
	_max_timer = 2.0
	Common.change_bg(Common.eBg.WHITE, 2.2)
func _move_WHITE(delta:float) -> void:
	_move_ANIM_PATTERN(delta)
	
	_spr.modulate = _spr.modulate.lerp(Color.BLACK, 10 * delta)
	
## 円形の衝撃波.
func _init_SHOCKWAVE_CIRCLE() -> void:
	_max_timer = 2.0
	var p = PARTICLE_SHOCK_WAVE2.instantiate()
	p.position = position
	p.setup(270, 10, 3.0, 0.0)
	_add_child(p)
func _move_SHOCKWAVE_CIRCLE(delta:float) -> void:
	_move_ANIM_PATTERN(delta)
	
## 矩形の衝撃波.
func _init_SHOCKWAVE_RECT() -> void:
	_max_timer = 2.0
func _move_SHOCKWAVE_RECT(delta:float) -> void:
	_move_ANIM_PATTERN(delta)
