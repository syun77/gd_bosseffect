extends Node2D

const ENEMY_OBJ = preload("res://src/Enemy.tscn")

@onready var _enemy_layer = $EnemyLayer
@onready var _particle_layer = $ParticleLayer

## 開始.
func _ready() -> void:
	var layers = {
		"enemy": _enemy_layer,
		"particle": _particle_layer,
	}

	Common.setup(layers)
	
	add_enemy()

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_click"):
		add_enemy()

## 敵を追加.
func add_enemy() -> void:
	var e = ENEMY_OBJ.instantiate()
	e.position = Vector2(800, 240)
	_enemy_layer.add_child(e)
	
