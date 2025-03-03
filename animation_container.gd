extends VBoxContainer

var animation_instance = load("res://animation.tscn")

@onready var scroll = $"../VScrollBar"

var cur_animation = 0
var data = {}

func play(number = 0):
	var children = get_children()
	for i in children.size()-1:
		if !(children[i] is CompilerAnimation):
			continue
		if i == number:
			children[i].play()
			cur_animation = i
			continue
		children[i].stop()


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

func _on_file_dialog_file_save(path: String) -> void:
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_line(JSON.stringify(data))
	
	CursorShit.save_path(path)

func _on_file_dialog_file_load(path: String) -> void:
	var children = get_children()
	data.clear()
	
	for i in children.size():
		if children[i] is CompilerAnimation || children[i] is FileDialog:
			children[i].queue_free()
		
	var file = FileAccess.open(path,FileAccess.READ)
	var _data = JSON.parse_string(file.get_as_text())
	
	for key in _data.keys():
		Renderer.frames.resize(_data[key].points.size())
		for frames in _data[key].points.size():
			for layers in _data[key].points[frames].size():
				if frames == 0:
					_data[key].modes[layers] = int(_data[key].modes[layers])
					_data[key].colors[layers] = string_to_col(_data[key].colors[layers])
					_data[key].pivots[layers] = string_to_vector2(_data[key].pivots[layers])
				for points in _data[key].points[frames][layers].size():
					_data[key].points[frames][layers][points] = string_to_vector2(_data[key].points[frames][layers][points])
			Renderer.frames[frames] = _data[key].points[frames]
				
			Renderer.points = _data[key].points[0]
			Renderer.mode = _data[key].modes
			Renderer.color = _data[key].colors
			Renderer.pivots = _data[key].pivots
			Renderer.fps = _data[key].fps
		
		var inst : CompilerAnimation = animation_instance.instantiate()
		inst.data = _data[key]
		add_child(inst)
		move_child(inst, 0)
		inst.on_play_pressed()
		inst.name_edit.text = key
		inst.animation_name = inst.name_edit.text
		
	CursorShit.save_path(path)
	
func _on_texture_button_4_pressed() -> void:
	var children = get_children()
	data.clear()
	for i in children.size()-1:
		var _data = children[i].data.duplicate(true)
		for frames in _data.points:
			for layers in frames:
				for points in layers:
					points-=Renderer.center
		for j in _data.pivots:
			j-=Renderer.center
			
		data[children[i].animation_name] = _data
	
	var dialog : FileDialog = FileDialog.new()
	
	dialog.visible = true
	dialog.access = 2
	dialog.file_mode = 4
	dialog.filters = PackedStringArray(["*.FILTHY"])
	dialog.current_dir = CursorShit.load_path()
	dialog.size = Vector2(750,500)
	dialog.position = Vector2(100,100)
	add_child(dialog)

	dialog.connect("file_selected", _on_file_dialog_file_save)
	dialog.connect("file_selected", dialog.queue_free)
	dialog.connect("canceled", dialog.queue_free)


func _on_texture_button_5_pressed() -> void:
	var dialog : FileDialog = FileDialog.new()
	
	dialog.visible = true
	dialog.access = 2
	dialog.file_mode = 0
	dialog.filters = PackedStringArray(["*.FILTHY"])
	dialog.current_dir = CursorShit.load_path()
	dialog.size = Vector2(750,500)
	dialog.position = Vector2(100,100)
	add_child(dialog)
	
	dialog.connect("file_selected", _on_file_dialog_file_load)
	dialog.connect("canceled", dialog.queue_free)


func _on_child_order_changed() -> void:
	if !scroll:
		return
	if (get_child_count()*104) - 750 > 0:
		scroll.visible = true
		
		scroll.max_value = get_child_count()*104.0-750.0
		scroll.value -= 104
		return
	scroll.visible = false
	
func _process(delta: float) -> void:
	if Renderer.can_shortcut:
		return
	if Input.is_action_just_released("ui_text_scroll_up"):
		scroll.value -= 20
	if Input.is_action_just_released("ui_text_scroll_down"):
		scroll.value += 20


func _on_v_scroll_bar_value_changed(value: float) -> void:
	position.y = clamp(((get_child_count()*104) - 750)*(-scroll.value/100), -INF, 0)
