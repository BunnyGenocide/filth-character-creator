extends PanelContainer
class_name CompilerAnimation

var data = {}
var animation_name = ""

var animation_instance = load("res://animation.tscn")

var par

@onready var name_edit = $Panel/TextEdit
@onready var fps_edit = $Panel/TextEdit2

@onready var play_button = $Panel/TextureButton
@onready var play_texture = load("res://play.png")
@onready var pause_texture = load("res://pause.png")

func _ready() -> void:
	par = get_parent()
	play_button.connect("pressed", on_play_pressed)
	animation_name = name_edit.text
	
func on_play_pressed():
	var children = par.get_children()
	for i in children.size():
		if children[i]==self:
			par.play(i)
			break

func play():
	var st = StyleBoxFlat.new()
	st.bg_color = Color.LIGHT_STEEL_BLUE
	add_theme_stylebox_override("panel", st)
	
	if play_button.texture_normal == pause_texture:
		play_button.texture_normal = play_texture
		play_button.texture_disabled = play_texture
		
		Renderer.animate=false
		return
		
	play_button.texture_normal = pause_texture
	play_button.texture_disabled = pause_texture
	
	Renderer.reset()
	
	var data = data.duplicate(true)
	
	Renderer.frames.resize(data.points.size())
	for frames in data.points.size():
		for layers in data.points[frames].size():
			if frames == 0:
				data.modes[layers] = data.modes[layers]
				data.colors[layers] = data.colors[layers]
				data.pivots[layers] = data.pivots[layers]
				if data.pivots[layers] != Vector2.INF:
					data.pivots[layers]+=Renderer.center
			for points in data.points[frames][layers].size():
				data.points[frames][layers][points] = data.points[frames][layers][points]+Renderer.center
		Renderer.frames[frames] = data.points[frames]
		
	Renderer.points = data.points[0]
	Renderer.mode = data.modes
	Renderer.color = data.colors
	Renderer.pivots = data.pivots
	Renderer.fps = data.fps
	
	fps_edit.text = str(Renderer.fps)
	
	Renderer.animate=true
	
func stop():
	play_button.texture_normal = play_texture
	play_button.texture_disabled = play_texture
	
	var st = StyleBoxFlat.new()
	st.bg_color = Color.DIM_GRAY
	add_theme_stylebox_override("panel", st)

func _on_texture_button_2_pressed() -> void:
	var children = par.get_children()
	var inst = animation_instance.instantiate()
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
	
	var _data = {
		"points": CursorShit.point_data,
		"colors": CursorShit.color_data,
		"modes": CursorShit.mode_data,
		"pivots": CursorShit.pivot_data,
		"fps": Renderer.fps
	}
	inst.data = _data
	for i in children.size():
		if children[i] == self:
			par.add_child(inst)
			par.move_child(inst, i+1)
			inst.name_edit.text= "animation" + str(children.size()-1)
			inst.animation_name = inst.name_edit.text
			return

func _on_texture_button_3_pressed() -> void:
	var children = par.get_children()
	if children.size()==2:
		return
	queue_free()


func _on_text_edit_2_focus_exited() -> void:
	var number = int(fps_edit.text)
	
	if number < 1:
		number = 1
	
	data.fps = number
	fps_edit.text = str(number)
	Renderer.fps=number


func _on_text_edit_text_changed() -> void:
	animation_name = name_edit.text
