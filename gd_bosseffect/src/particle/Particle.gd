extends Sprite2D

# ============================================
# パーティクル基底クラス.
# ============================================
class_name Particle

var _cnt = 0 # move呼び出し回数.
var _deg = 0.0 # 移動方向.
var _speed = 0.0 # 移動速度.
var _decay = 0.97 # 減衰率.
var _life = 1.0 # 生存時間.
var _timer = 0.0 # 経過時間.
var _is_auto_destroy = true

## セットアップ.
func setup(deg:float, speed:float, life:float, sc:float=1.0, decay:float=0.97):
	_deg = deg
	_speed = speed
	_life = life
	scale = Vector2(sc, sc)
	_decay = decay

## 移動量を取得する.
func get_velocity() -> Vector2:
	var rad = deg_to_rad(_deg)
	var v = Vector2(
		_speed * cos(rad),
		_speed * -sin(rad)
	)
	return v

## 移動する.
func move(delta:float) -> void:
	_cnt += 1
	_speed *= _decay
	var v = get_velocity()
	position += v * delta
	
	_timer += delta
	
	if _is_auto_destroy and is_end():
		# 自動で消滅.
		queue_free()
	
## 経過時間を 0.0 〜 1.0 で取得する.
func get_time_rate() -> float:
	var rate = _timer / _life
	if rate > 1:
		return 1
	return rate

## 終了したかどうか.
func is_end() -> bool:
	return _timer >= _life

## 開始.
func _ready() -> void:
	pass

## 更新.
func _physics_process(delta: float) -> void:
	move(delta)
	
	if is_end():
		queue_free()
