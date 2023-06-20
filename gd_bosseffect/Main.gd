extends Node2D

const ENEMY_OBJ = preload("res://src/Enemy.tscn")
const TIMER_SHAKE = 1.0

@onready var _bg2 = $Bg2
@onready var _bg = $Bg
@onready var _bg_color = $Bg/ColorRect
@onready var _mask = $Mask
@onready var _mask_bg = $Mask/Bg
@onready var _camera = $Camera2D
@onready var _option = $UILayer/OptionButton
@onready var _enemy_layer = $EnemyLayer
@onready var _particle_layer = $ParticleLayer

@export var enemy_type:Enemy.eType

var _cnt = 0.0
var _exists_enemy = false
var _prev_cnt = 0
var _prev_shake_y = 0.0
var _dont_shake = false


## 開始.
func _ready() -> void:
	var layers = {
		"enemy": _enemy_layer,
		"particle": _particle_layer,
	}
	# セットアップ.
	Common.setup(layers)
	
	# ドロップダウンリストを設定.
	for k in Enemy.eType.keys():
		_option.add_item(k)
	_option.select(enemy_type)
	
	# 敵を生成しておく.
	add_enemy()

## 更新.
func _process(delta: float) -> void:
	Common.update_slow(delta)
	
	_cnt += Common.get_slow_rate()
	if Input.is_action_just_pressed("ui_rclick"):
		# 右クリックで敵を生成.
		add_enemy()
	
	delta *= Common.get_slow_rate()
	_update_shake(delta)
	_update_bg(delta)
	
	_prev_cnt = _cnt

## 敵を追加.
func add_enemy() -> void:
	var e = ENEMY_OBJ.instantiate()
	_enemy_layer.add_child(e)
	e.position = Vector2(800, 240)
	e.set_type(_option.selected)
	
## 画面を揺らす.
func _update_shake(delta:float) -> void:
	var prev = _exists_enemy
	_exists_enemy = _enemy_layer.get_child_count() > 0
	if prev:
		if _exists_enemy == false:
			if _dont_shake == false:
				# 敵が消えたら画面を揺らす.
				Common.start_shake()
			_dont_shake = false
	
	if Common.update_shake(delta) == false:
		_camera.offset = Vector2.ZERO
		return
		
	var rate = Common.get_shake_rate() * Common.shake_power
	var x_mul = 1 if int(_cnt)%4 < 2 else -1
	_camera.offset.x = 32 * rate * x_mul
	if _prev_cnt != int(_cnt):
		# 値が変わったら乱数を引く.
		_prev_shake_y = randf_range(-24, 24)
	_camera.offset.y = _prev_shake_y * rate
	
## 背景の更新.
func _update_bg(delta:float) -> void:
	_bg_color.visible = false
	if Common.update_bg(delta) == false:
		return
	
	var type = Common.bg_type
	var rate = Common.get_bg_rate()
	
	match type:
		Common.eBg.WHITE:
			_bg_color.visible = true
			if rate < 0.8:
				rate = 1.0
			else:
				rate = 1.0 - (rate - 0.8) / 0.2
			_bg_color.color.a = rate
		Common.eBg.RASTER:
			_dont_shake = true
			var mat:ShaderMaterial = _mask_bg.material
			if rate < 0.3:
				_bg2.visible = true
				_mask.scale.x = 0.75 * randf_range(0.9, 1.1)
				_mask.scale.y = 0.75 * randf_range(0.9, 1.1)
				_mask.skew = randf_range(-0.1, 0.1)
				var rate2 = rate / 0.3
				var white = Color.WHITE
				_bg2.modulate = white.lerp(Color.BLACK, rate2)
				_bg.visible = false
				mat.set_shader_parameter("is_binarization", true)
				mat.set_shader_parameter("is_horizontal", false)
				mat.set_shader_parameter("time", randf_range(0, 1000))
				
			elif rate < 0.5:
				mat.set_shader_parameter("time", randf_range(0, 1000))
				mat.set_shader_parameter("is_horizontal", true)
				var enemy = _enemy_layer.get_child(0)
				var rate2 = (rate - 0.3) / 0.2
				_mask.scale.x = 0.75 + 30 * Ease.expo_out(rate2)
				_mask.scale.y = 1 * Ease.expo_in(1 - rate2)
				_mask.skew = 0
				_bg.visible = false
				if rate2 > 0.9:
					Common.start_shake()
					var spd = 700
					for i in range(32):
						var rot = 360 * i / 32.0
						enemy._add_particle(rot, spd, 2.0)					
			elif rate < 0.8:
				_bg2.visible = false
				_bg.visible = true
				var rate2 = (rate - 0.5) / 0.3
				mat.set_shader_parameter("time", 100*rate2)
			else:
				# 2値化とラスター処理を終了.
				mat.set_shader_parameter("is_binarization", false)
				var rate2 = 1.0 - (rate - 0.9) / 0.1
				mat.set_shader_parameter("time", 100*Ease.cube_in(rate2))
				_bg.visible = true
				_bg_color.visible = true
				_bg_color.color.a = rate2
				
