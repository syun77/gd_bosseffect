extends Node2D

const ENEMY_OBJ = preload("res://src/Enemy.tscn")

@onready var _option = $UILayer/OptionButton
@onready var _enemy_layer = $EnemyLayer
@onready var _particle_layer = $ParticleLayer

@export var enemy_type:Enemy.eType

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
	if Input.is_action_just_pressed("ui_rclick"):
		# 右クリックで敵を生成.
		add_enemy()

## 敵を追加.
func add_enemy() -> void:
	var e = ENEMY_OBJ.instantiate()
	_enemy_layer.add_child(e)
	e.position = Vector2(800, 240)
	e.set_type(_option.selected)
	
