
extends Node2D

# 地图尺寸，单位为格子
@export var map_width: int = 80
@export var map_height: int = 60

# 是否显示调试信息
@export var show_debug_log: bool = false

# 是否启用格子高亮
@export var show_hover_highlight: bool = true

# 高亮颜色
@export var highlight_fill: Color = Color(0.25, 0.95, 0.45, 0.20)
@export var highlight_outline: Color = Color(0.35, 1.0, 0.45, 1.0)

# 地面图层
@onready var ground: TileMapLayer = $"../Ground"

# 当前鼠标所在格子
var _hover_cell: Vector2i = Vector2i(-999, -999)

# 当前是否显示高亮
var _hover_visible: bool = false


func _ready() -> void:
	# 确保高亮绘制在地面上方
	z_index = 100


# 世界坐标 -> 网格坐标
func world_to_cell(world_position: Vector2) -> Vector2i:
	var local_position: Vector2 = ground.to_local(world_position)
	return ground.local_to_map(local_position)


# 网格坐标 -> 格子中心的世界坐标
func cell_to_world(cell: Vector2i) -> Vector2:
	var local_position: Vector2 = ground.map_to_local(cell)
	return ground.to_global(local_position)


# 判断格子是否在地图范围内
func is_inside_map(cell: Vector2i) -> bool:
	return (
		cell.x >= 0
		and cell.x < map_width
		and cell.y >= 0
		and cell.y < map_height
	)


# 获取鼠标所在格子
func get_mouse_cell() -> Vector2i:
	return world_to_cell(get_global_mouse_position())


# 检测鼠标是否换格
func _process(_delta: float) -> void:
	if not show_hover_highlight:
		if _hover_visible:
			_hover_visible = false
			queue_redraw()
		return

	var cell: Vector2i = get_mouse_cell()
	var inside: bool = is_inside_map(cell)

	if cell != _hover_cell or inside != _hover_visible:
		_hover_cell = cell
		_hover_visible = inside

		# 只有换格或显示状态改变时才重绘
		queue_redraw()

		if show_debug_log:
			print(
				"网格坐标：", cell,
				" | 格子中心：", cell_to_world(cell),
				" | 位于地图内：", inside
			)


# 绘制悬停格子
func _draw() -> void:
	if not _hover_visible:
		return

	if ground.tile_set == null:
		return

	# TileSet 中定义的真实格子尺寸
	var tile_size: Vector2 = Vector2(ground.tile_set.tile_size)

	# 获取格子中心，并转换为 GridManager 的局部坐标
	var center: Vector2 = to_local(cell_to_world(_hover_cell))

	# 因为中心点是格子中心，所以向四周各扩展半格
	var rect := Rect2(
		center - tile_size * 0.5,
		tile_size
	)

	# 半透明填充
	draw_rect(rect, highlight_fill, true)

	# 绘制绿色边框
	draw_rect(rect, highlight_outline, false, 1.0)
