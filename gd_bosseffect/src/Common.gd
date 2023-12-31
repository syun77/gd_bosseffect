extends Node

enum eBg {
	NONE,
	WHITE,
	RASTER,
}

var shake_power = 0.0
var shake_time = 0.0
var shake_max_time = 0.0

var _slow_time = 0.0
var _slow_rate = 1.0

var bg_type:eBg
var bg_time = 0.0
var bg_max_time = 0.0

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

## スロー開始.
func start_slow(rate:float=0.3, time:float=1.0) -> void:
	_slow_rate = rate
	_slow_time = time

func update_slow(delta:float) -> void:
	if _slow_time >= 0.0:
		_slow_time -= delta

func get_slow_rate() -> float:
	if _slow_time <= 0.0:
		return 1.0
	return _slow_rate

## 背景変更.
func change_bg(type:eBg, time:float=1.0) -> void:
	bg_type = type
	bg_time = 0.0
	bg_max_time = time
func update_bg(delta:float) -> bool:
	if bg_time < bg_max_time:
		bg_time += delta
		return true
	return false

func get_bg_rate() -> float:
	if bg_time > bg_max_time:
		return 1.0
	return bg_time / bg_max_time
