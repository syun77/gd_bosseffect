extends Node2D

const ENEMY_OBJ = preload("res://src/Enemy.tscn")
const TIMER_SHAKE = 1.0

@onready var _camera = $Camera2D
@onready var _option = $UILayer/OptionButton
@onready var _enemy_layer = $EnemyLayer
@onready var _particle_layer = $ParticleLayer

@export var enemy_type:Enemy.eType

var _cnt = 0
var _exists_enemy = false


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
	_cnt += 1
	if Input.is_action_just_pressed("ui_rclick"):
		# 右クリックで敵を生成.
		add_enemy()
	
	_update_shake(delta)

## 敵を追加.
func add_enemy() -> void:
	var e = ENEMY_OBJ.instantiate()
	_enemy_layer.add_child(e)
	e.position = Vector2(800, 240)
	e.set_type(_option.selected)
	
## 画面を揺らす.
func _update_shake(delta:float):
	var prev = _exists_enemy
	_exists_enemy = _enemy_layer.get_child_count() > 0
	if prev:
		if _exists_enemy == false:
			# 敵が消えたら画面を揺らす.
			Common.start_shake()
	
	if Common.update_shake(delta) == false:
		_camera.offset = Vector2.ZERO
		return
		
	var rate = Common.get_shake_rate() * Common.shake_power
	var x_mul = 1 if _cnt%4 < 2 else -1
	_camera.offset.x = 32 * rate * x_mul
	_camera.offset.y = randf_range(-24, 24) * rate
