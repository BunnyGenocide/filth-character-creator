extends TextureButton

@export var tool: CursorShit.tools
@export var is_tool: bool = true
@onready var pencil = $"../TextureButton"

var mirror = 1
var open_sprite = load("res://open_sprite.tscn")

@onready var pivot_textures = [load("res://pivot.png"),
load("res://locked_pivot.png")]

@onready var mirror_textures = [load("res://mirror1.png"),
load("res://mirror2.png"),
load("res://mirror3.png"),
load("res://mirror4.png")
]
@onready var rfood_textures = [load("res://rfood.png"),
load("res://rfood2.png"),
]
@onready var point_textures = [load("res://hide_points.png"),
load("res://points.png"),
]

@onready var play_textures = [load("res://play.png"),
load("res://pause.png"),
]

@onready var mode_textures = [load("res://connect_mode.png"),
load("res://line_mode.png"),
load("res://polygon_mode.png"),
]

@onready var visible_textures = [load("res://visible.png"),
load("res://invisible.png"),
]

func _ready() -> void:
	connect("focus_entered", _on_focus_entered)

func _process(delta: float) -> void:
	if tool == CursorShit.tools.Visible:
		if Renderer.visible_layers[Renderer.cur_layer-1] == true:
			texture_normal=visible_textures[0]
			texture_disabled=visible_textures[0]
		else:
			texture_normal=visible_textures[1]
			texture_disabled=visible_textures[1]
	if tool == CursorShit.tools.LineMode:
		if Renderer.mode[Renderer.cur_layer-1] == 0:
			texture_normal=mode_textures[0]
			texture_disabled=mode_textures[0]
		elif Renderer.mode[Renderer.cur_layer-1] == 1:
			texture_normal=mode_textures[1]
			texture_disabled=mode_textures[1]
		else:
			texture_normal=mode_textures[2]
			texture_disabled=mode_textures[2]
	if tool != CursorShit.tools.Draw:
		return
		
	pencil.modulate = Renderer.color[Renderer.cur_layer-1]
	
func _input(ev):
	if tool != CursorShit.tools.Play:
		return
	if Input.is_key_pressed(KEY_SPACE):
		Renderer.animate=!Renderer.animate
		if Renderer.animate == true:
			texture_normal=play_textures[1]
			texture_disabled=play_textures[1]
		else:
			texture_normal=play_textures[0]
			texture_disabled=play_textures[0]
			
func _on_file_dialog_file_save(path: String) -> void:
	var data = {
		"points": CursorShit.point_data,
		"colors": CursorShit.color_data,
		"modes": CursorShit.mode_data,
		"pivots": CursorShit.pivot_data,
		"fps": Renderer.fps
	}
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	
	CursorShit.save_path(path)
	
static func string_to_col(string := "") -> Color:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")
		
		return Color(float(array[0]),float(array[1]),float(array[2]),float(array[3]))
	return Color.DARK_GRAY
static func string_to_vector2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string = new_string.erase(0, 1)
		new_string = new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")
		
		if array[0] == "inf":
			array[0] = INF
		if array[1] == "inf":
			array[1] = INF

		return Vector2(float(array[0]), float(array[1]))

	return Vector2.ZERO
	
func _on_file_dialog_file_load(path: String) -> void:
	Renderer.reset()
	
	var file = FileAccess.open(path,FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text()) 
	Renderer.frames.resize(data.points.size())
	for frames in data.points.size():
		for layers in data.points[frames].size():
			if frames == 0:
				data.modes[layers] = int(data.modes[layers])
				data.colors[layers] = string_to_col(data.colors[layers])
				data.pivots[layers] = string_to_vector2(data.pivots[layers])
				if data.pivots[layers] != Vector2.INF:
					data.pivots[layers]+=Renderer.center
			for points in data.points[frames][layers].size():
				data.points[frames][layers][points] = string_to_vector2(data.points[frames][layers][points])+Renderer.center
		Renderer.frames[frames] = data.points[frames]
		
	Renderer.points = data.points[0]
	Renderer.mode = data.modes
	Renderer.color = data.colors
	Renderer.pivots = data.pivots
	Renderer.fps = data.fps
	
	CursorShit.save_path(path)
	
func press():
	if !is_tool:
		match tool:
			CursorShit.tools.Pencil_Color:
				Renderer.color[Renderer.cur_layer-1] = modulate
			CursorShit.tools.Compiler:
				Renderer.save_frame()
				CursorShit.point_data = []
				CursorShit.color_data = Renderer.color
				CursorShit.mode_data = Renderer.mode
				CursorShit.pivot_data = Renderer.pivots.duplicate(true)
				for layer in Renderer.points.size():
					if CursorShit.pivot_data[layer] != Vector2.INF:
						CursorShit.pivot_data[layer] -= Renderer.center
				for frame in Renderer.frames.duplicate(true):
					var f = []
					for layer in frame:
						for point in layer.size():
							layer[point] -= Renderer.center
						f.push_back(layer)
					CursorShit.point_data.push_back(f)
				
				var data = {
					"points": CursorShit.point_data,
					"colors": CursorShit.color_data,
					"modes": CursorShit.mode_data,
					"pivots": CursorShit.pivot_data,
					"fps": Renderer.fps
				}
				
				var cp = get_tree().get_nodes_in_group("compiler")[0]
				var ba = get_tree().get_nodes_in_group("build_area")[0]
				
				Renderer.compiling = true
				cp.visible = true
				cp.save_data(data)
				ba.visible = false
				
			CursorShit.tools.Load:
				var dialog = FileDialog.new()
				
				dialog.visible = true
				dialog.access = 2
				dialog.file_mode = 0
				dialog.filters = PackedStringArray(["*.TRASH"])
				dialog.current_dir = CursorShit.load_path()
				dialog.size = Vector2(750,500)
				dialog.position = Vector2(100,100)
				add_child(dialog)

				dialog.connect("file_selected", _on_file_dialog_file_load)
				dialog.connect("file_selected", dialog.queue_free)
				dialog.connect("canceled", dialog.queue_free)
			CursorShit.tools.Save:
				Renderer.save_frame()
				CursorShit.point_data = []
				CursorShit.color_data = Renderer.color
				CursorShit.mode_data = Renderer.mode
				CursorShit.pivot_data = Renderer.pivots.duplicate(true)
				for layer in Renderer.points.size():
					if CursorShit.pivot_data[layer] != Vector2.INF:
						CursorShit.pivot_data[layer] -= Renderer.center
				for frame in Renderer.frames.duplicate(true):
					var f = []
					for layer in frame:
						for point in layer.size():
							layer[point] -= Renderer.center
						f.push_back(layer)
					CursorShit.point_data.push_back(f)
					
				var dialog = FileDialog.new()
				
				dialog.visible = true
				dialog.access = 2
				dialog.file_mode = 4
				dialog.filters = PackedStringArray(["*.TRASH"])
				dialog.current_dir = CursorShit.load_path()
				dialog.size = Vector2(750,500)
				dialog.position = Vector2(100,100)
				add_child(dialog)

				dialog.connect("file_selected", _on_file_dialog_file_save)
				dialog.connect("file_selected", dialog.queue_free)
				dialog.connect("canceled", dialog.queue_free)
			CursorShit.tools.Pivot:
				if Input.is_key_pressed(KEY_SHIFT):
					Renderer.pivot_locked = !Renderer.pivot_locked
					if Renderer.pivot_locked:
						texture_normal=pivot_textures[1]
						texture_disabled=pivot_textures[1]
					else:
						texture_normal=pivot_textures[0]
						texture_disabled=pivot_textures[0]
					return
				if Renderer.selected_points[0].size() >= 1:
					var highest = -Vector2.INF
					var lowest = Vector2.INF
					var m_pos = Vector2.ZERO
					for i in Renderer.selected_points[1]:
						if highest.x < Renderer.points[i[0]][i[1]].x:
							highest.x = Renderer.points[i[0]][i[1]].x
						if highest.y < Renderer.points[i[0]][i[1]].y:
							highest.y = Renderer.points[i[0]][i[1]].y
						if lowest.x > Renderer.points[i[0]][i[1]].x:
							lowest.x = Renderer.points[i[0]][i[1]].x
						if lowest.y > Renderer.points[i[0]][i[1]].y:
							lowest.y = Renderer.points[i[0]][i[1]].y
					m_pos = (highest+lowest)/2
					Renderer.pivots[Renderer.cur_layer-1] = m_pos
				else:
					Renderer.pivots[Renderer.cur_layer-1] = Vector2.INF
			CursorShit.tools.LineMode:
				if Renderer.mode[Renderer.cur_layer-1] == 0:
					Renderer.mode[Renderer.cur_layer-1] = 1
				elif Renderer.mode[Renderer.cur_layer-1] == 1:
					Renderer.mode[Renderer.cur_layer-1] = 2
				else:
					Renderer.mode[Renderer.cur_layer-1] = 0
			CursorShit.tools.Visible:
				Renderer.visible_layers[Renderer.cur_layer-1] = !Renderer.visible_layers[Renderer.cur_layer-1]
				
				var new_selected = [[],[]]
				for i in Renderer.selected_points[1].size():
					if Renderer.visible_layers[Renderer.selected_points[1][i][0]] == false:
						continue
					new_selected[0].push_back(Renderer.selected_points[0][i])
					new_selected[1].push_back(Renderer.selected_points[1][i])
				Renderer.selected_points = new_selected.duplicate()
			CursorShit.tools.Left:
				if Renderer.cur_frame!= 1 && Input.is_key_pressed(KEY_SHIFT):
					var jump = 1
					if Renderer.cur_frame == 2:
						jump=0
						
					Renderer.frames.insert(Renderer.cur_frame,Renderer.frames[Renderer.cur_frame-2].duplicate())
					Renderer.change_frame(-1)
					Renderer.remove_frame()
					Renderer.change_frame(jump)
					return
				Renderer.change_frame(-1)
			CursorShit.tools.Right:
				if Renderer.frames.size()!=Renderer.cur_frame && Input.is_key_pressed(KEY_SHIFT):
					var jump = 1
					if Renderer.cur_frame != 1:
						jump=2
					
					Renderer.frames.insert(Renderer.cur_frame+1,Renderer.frames[Renderer.cur_frame-1].duplicate())
					Renderer.remove_frame()
					Renderer.change_frame(jump)
					return
				Renderer.change_frame(1)
			CursorShit.tools.Up:
				Renderer.cur_layer+=1
				Renderer.cur_layer = clamp(Renderer.cur_layer,1,10)
			CursorShit.tools.Down:
				Renderer.cur_layer-=1
				Renderer.cur_layer = clamp(Renderer.cur_layer,1,10)
			CursorShit.tools.Plus:
				Renderer.add_frame()
			CursorShit.tools.Minus:
				Renderer.remove_frame()
			CursorShit.tools.Play:
				Renderer.animate=!Renderer.animate
				if Renderer.animate == true:
					texture_normal=play_textures[1]
					texture_disabled=play_textures[1]
				else:
					texture_normal=play_textures[0]
					texture_disabled=play_textures[0]
			CursorShit.tools.ColorPick:
				var cp = get_tree().get_nodes_in_group("color_picker")[0]
				var ba = get_tree().get_nodes_in_group("build_area")[0]
				
				Renderer.compiling = true
				cp.visible = true
				ba.visible = false
				#match Renderer.color[Renderer.cur_layer-1]:
					#Color.WHITE:
					#	Renderer.color[Renderer.cur_layer-1] = Color(1,0,0)
						
					#Color(1,0,0):
					#	Renderer.color[Renderer.cur_layer-1] = Color(0,1,0)
						
					#Color(0,1,0):
					#	Renderer.color[Renderer.cur_layer-1] = Color(0,0,1)
						
					#Color(0,0,1):
					#	Renderer.color[Renderer.cur_layer-1] = Color(1,1,0)
						
					#Color(1,1,0):
					#	Renderer.color[Renderer.cur_layer-1] = Color(0,1,1)
					
					#Color(0,1,1):
					#	Renderer.color[Renderer.cur_layer-1] = Color(1,0,1)
						
					#Color(1,0,1):
					#	Renderer.color[Renderer.cur_layer-1] = Color.WHITE
			CursorShit.tools.HidePoints:
				Renderer.hide_points=!Renderer.hide_points
				if Renderer.hide_points:
					texture_normal=point_textures[0]
					texture_disabled=point_textures[0]
				else:
					texture_normal=point_textures[1]
					texture_disabled=point_textures[1]
			CursorShit.tools.OnionSkin:
				Renderer.onion_skin = !Renderer.onion_skin
				if Renderer.onion_skin:
					texture_normal=rfood_textures[0]
					texture_disabled=rfood_textures[0]
				else:
					texture_normal=rfood_textures[1]
					texture_disabled=rfood_textures[1]
			CursorShit.tools.Mirror:
				mirror+=1
				if mirror>4:
					mirror=1
				
				texture_normal=mirror_textures[mirror-1]
				texture_disabled=mirror_textures[mirror-1]
				
				CursorShit.mirror = mirror-1
		return
	if Input.is_key_pressed(KEY_SHIFT) && tool == CursorShit.tools.Guy:
		add_child(open_sprite.instantiate())
		return
		
	if CursorShit.tool == tool:
		return
	CursorShit.tool = tool
	CursorShit.change_cursor()
func _pressed() -> void:
	press()

func _on_focus_entered() -> void:
	release_focus()
