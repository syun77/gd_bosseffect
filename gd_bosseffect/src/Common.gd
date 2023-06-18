extends Node

var shake_power = 0.0
var shake_time = 0.0
var shake_max_time = 0.0

var _layers = {}

## セットアップ.
func setup(layer) -> void:
	_layers = layer

func get_layer(name:String) -> CanvasLayer:
	return _layers[name]

## 揺れ開始.
func start_shake(power:float=1.0, time:float=1.0) -> void:
	shake_time = time
	shake_max_time = time
	shake_power = power

func update_shake(delta:float) -> bool:
	shake_time -= delta
	if shake_time <= 0.0:
		return false
	return true

func get_shake_rate() -> float:
	return shake_time / shake_max_time
