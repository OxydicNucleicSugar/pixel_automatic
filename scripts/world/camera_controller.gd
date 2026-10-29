extends Camera2D

# 相机移动速度，单位为世界坐标像素/秒
@export var move_speed: float = 400.0

# 每次滚动鼠标滚轮时的缩放倍率
@export var zoom_step: float = 1.2

# 缩放范围
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0


func _process(delta: float) -> void:
	# 获取键盘输入方向，自动处理斜向移动
	var direction := Input.get_vector(
		"left",
		"right",
		"up",
        "down"
	)

	# 移动相机
	position += direction * move_speed * delta


func _unhandled_input(event: InputEvent) -> void:
	# 处理鼠标滚轮
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_change_zoom(zoom.x * zoom_step)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_change_zoom(zoom.x / zoom_step)


func _change_zoom(value: float) -> void:
	# 限制缩放范围
	var new_zoom := clampf(value, min_zoom, max_zoom)

	# 保持横向和纵向缩放一致
	zoom = Vector2(new_zoom, new_zoom)
