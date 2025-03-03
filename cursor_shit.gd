extends Node2D

enum tools{
	Selector,
	Draw,
	Guy,
	LineMode,
	ColorPick,
	HidePoints,
	OnionSkin,
	Mirror,
	Move,
	Grid,
	Play,
	Scale,
	Rotate,
	Up,
	Down,
	Left,
	Right,
	Plus,
	Minus,
	Visible,
	Save,
	Load,
	Pivot,
	Compiler,
	Pencil_Color
}
var tool: tools

@onready var draw_cursor = load("res://draw_cursor.png")
@onready var move_cursor = load("res://move_cursor.png")
@onready var selected_cursor = load("res://cursor.png")
@onready var man = load("res://theman.png")
@onready var scale_cursor = load("res://scale_cursor.png")
@onready var rotate_cursor = load("res://rotate_cursor.png")

enum mirrors{
	None,
	Horizontal,
	Vertical,
	All
}

var point_data = []
var color_data = []
var mode_data = []
var pivot_data = []

var mirror: mirrors
var scale_factor = Vector2.ZERO
var move_factor = Vector2.ZERO
var points_start_pos = []
var pivot_start_pos = Vector2.ZERO
var move_offset = Vector2.ZERO
var angle = 0

func _ready() -> void:
	change_cursor()

func change_cursor() -> void:
	scale_factor = Vector2.ZERO
	move_factor = Vector2.ZERO
	pivot_start_pos = Vector2.ZERO
	points_start_pos = [[],[],[]]
	move_offset = Vector2.ZERO
	angle = 0
	if tool == tools.Scale:
		DisplayServer.cursor_set_custom_image(scale_cursor, 0, Vector2(0,0))
		var a = 0
		for i in Renderer.selected_points[1]:
			points_start_pos[0].push_back(Renderer.points[i[0]][i[1]])
			points_start_pos[1].push_back([i[0], i[1], a])
			a+=1
		return
	if tool == tools.Rotate:
		DisplayServer.cursor_set_custom_image(rotate_cursor, 0, Vector2(0,0))
		var a = 0
		for i in Renderer.selected_points[1]:
			points_start_pos[0].push_back(Renderer.points[i[0]][i[1]])
			points_start_pos[1].push_back([i[0], i[1], a])
			a+=1
		return
	if tool == tools.Selector:
		DisplayServer.cursor_set_custom_image(selected_cursor, 0, Vector2(0,0))
		return
	if tool == tools.Guy:
		DisplayServer.cursor_set_custom_image(man, 0, Vector2(0,0))
		return
	if tool == tools.Move:
		DisplayServer.cursor_set_custom_image(move_cursor, 0, Vector2(0,0))
		move_factor = get_global_mouse_position()
		pivot_start_pos = Renderer.pivots[Renderer.cur_layer-1]
		var a = 0
		for i in Renderer.selected_points[1]:
			points_start_pos[0].push_back(Renderer.points[i[0]][i[1]])
			points_start_pos[1].push_back([i[0], i[1], a])
			a+=1
		return
	DisplayServer.cursor_set_custom_image(draw_cursor, 0, Vector2(0,16))
	
func save_path(path):
	var a = {
	"path": path
	}

	var save_file = FileAccess.open("user://filth_editor.path", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(a))

	save_file.close()
	
func load_path() -> String:
	if FileAccess.file_exists("user://filth_editor.path"):
		var file = FileAccess.open("user://filth_editor.path",FileAccess.READ)
		var result = JSON.parse_string(file.get_as_text()).path
		while !result.ends_with("/"):
			result = result.left(-1)
		
		return result
	
	var username = "Default"
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
	return "C:/Users/" + username + "/Desktop"
