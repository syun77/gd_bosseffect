extends Node

var _layers = {}

## セットアップ.
func setup(layer) -> void:
	_layers = layer

func get_layer(name:String) -> CanvasLayer:
	return _layers[name]
