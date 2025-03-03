extends Camera2D

@onready var factor = get_viewport_rect().size

func _ready() -> void:
	position = Renderer.center

func _process(delta: float) -> void:
	queue_redraw()
	if !Renderer.can_shortcut:
		return
	if Input.is_action_just_released("ui_text_scroll_up"):
		zoom += Vector2.ONE
	if Input.is_action_just_released("ui_text_scroll_down"):
		zoom -= Vector2.ONE
		
	Renderer.factor=1/((zoom.x+zoom.y)/2)

func _draw() -> void:
	if Renderer.compiling || CursorShit.tool == CursorShit.tools.Scale || CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate:
		return
	if Renderer.selected_points[0].size() >= 1:
		var min = INF
		var max = -INF
		for i in Renderer.selected_points[1]:
			if i[1] < min:
				min = i[1]
			if i[1] > max:
				max = i[1]
		draw_string(FontFile.new(),Vector2(-factor.x/3,-factor.y/3)*Renderer.factor, "Place: " + str(min) +" <-> " + str(max))
		draw_string(FontFile.new(),Vector2(-factor.x/3,-factor.y/3.5), "Press , or . to move place")
		return
	
	draw_string(FontFile.new(),Vector2(-factor.x/3,-factor.y/3)*Renderer.factor, "Cur Layer: " + str(Renderer.cur_layer)+"/10"+" | Cur Frame:" + str(Renderer.cur_frame)+"/"+str(Renderer.frames.size()))
