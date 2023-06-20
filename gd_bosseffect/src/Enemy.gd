extends Node2D

# ==========================================
# 敵.
# ==========================================
class_name Enemy

# ------------------------------------------
# preload.
# ------------------------------------------
const PARTICLE_EXPLOSION = preload("res://src/particle/ParticleExplosion.tscn")
const PARTICLE_SHOCK_WAVE = preload("res://src/particle/ParticleShockWave.tscn")
const PARTICLE_SHOCK_WAVE2 = preload("res://src/particle/ParticleShockWave2.tscn")
const PARTICLE_RECT = preload("res://src/particle/ParticleRect.tscn")
const PARTICLE_CIRCLE_WHITE = preload("res://src/particle/ParticleCircleWhite.tscn")

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
	RAY,
	FLASH,
	WHITE,
	SPECIAL,
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
var _cnt2 = 0.0
var _step = 0
var _timer = 0.0
var _max_timer = 3.0
var _velocity = Vector2()
var _color = Color.WHITE
var _color_time = 0.0
var _color_max_time = 0.0
var _ray_list = []

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

func change_color(color:Color, time=1.0) -> void:
	_color = color
	_color_max_time = time
	_color_time = time
	
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
		eType.RAY:
			# 白い円が拡大.
			var p = PARTICLE_CIRCLE_WHITE.instantiate()
			p.position = position
			p.setup(0, 0, 1.5)
			_add_child(p)
			var spd = 700
			for i in range(32):
				var rot = 360 * i / 32.0
				_add_particle(rot, spd, 2.0)
		eType.SHOCKWAVE_RECT:
			var p = PARTICLE_RECT.instantiate()
			p.position = position
			p.setup(0, 0, 1.5)
			p.color = Color.RED
			_add_child(p)
		eType.SPECIAL:
			pass
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
	
## 更新.
func _physics_process(delta: float) -> void:
	delta *= Common.get_slow_rate()
	
	_cnt += 1 * Common.get_slow_rate()
	_timer += delta
	
	# 移動.
	_move(delta)
	
	_update_color(delta)
	
	if _timer >= _max_timer:
		destroy()
		queue_free()
	
	queue_redraw()

## 描画.
func _draw() -> void:
	var funcname = "_draw_" + eType.keys()[_id]
	if has_method(funcname):
		# 描画関数があれば呼び出し.
		call(funcname)

## 色の更新.
func _update_color(delta:float) -> void:
	if _color_time <= 0.0:
		return
	
	_color_time -= delta
	if _color_time <= 0.0:
		modulate = Color.WHITE
		return
	
	var rate = _color_time / _color_max_time
	if _id == eType.RAY:
		rate = 1 - rate # 光線の場合は逆.
	modulate = Color.WHITE.lerp(_color, rate)

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

	_velocity *= 0.85
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
				set_velocity(180, 1000) # 爆発の反動.
				Common.start_shake(0.2, 1) # 少し揺らす.
				change_color(Color.RED)
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
				set_velocity(0, 1000) # 爆発の反動.
				Common.start_shake(0.2, 1) # 少し揺らす.
				change_color(Color.RED)
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
	
## 光線.
func _init_RAY() -> void:
	_cnt = 20
func _move_RAY(delta:float) -> void:
	_move_ANIM_PATTERN(delta)
	
	_cnt2 += Common.get_slow_rate()
	if _cnt2 > 20 and _ray_list.size() < 5:
		var rad = _timer * 8 + randf_range(0, 0.5)
		_ray_list.push_back(rad)
		if _ray_list.size() >= 5:
			change_color(Color.RED, _max_timer - _timer)
		_cnt2 -= randf_range(15, 25)
func _draw_RAY() -> void:
	var idx = 0
	for rad in _ray_list:
		var dist = SIZE * 0.01 + 0.01 * (idx%2)
		var ofs = Vector2(
			dist * cos(rad),
			dist * -sin(rad)
		)
		var vlist = [ofs]
		var c = Color.WHITE
		if int(_cnt)%2 == 0:
			c.a = 0.0
		var clist = [c, c, c]
		vlist.push_back(ofs + Vector2(
			2048 * cos(rad + 0.02),
			2048 * sin(rad + 0.1)
		))
		vlist.push_back(ofs + Vector2(
			2048 * cos(rad - 0.05),
			2048 * sin(rad - 0.1)
		))
		draw_polygon(vlist, clist)
		
		idx += 1

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

## 特殊.
func _init_SPECIAL() -> void:
	_max_timer = 7.0
	Common.change_bg(Common.eBg.RASTER, _max_timer)
func _move_SPECIAL(delta:float) -> void:
	if _timer < 0.5:
		var rate = 1 - _timer / 0.5
		modulate.a = rate
