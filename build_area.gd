extends Button

var selected_prev = []
var selected_pos = [Vector2.ZERO, Vector2.ZERO]
var deselect = false

func _pressed() -> void:
	draw()
	guy()
func _process(delta: float) -> void:
	select()
	scale()
	move()
	rotate()
func _input(event):
	if CursorShit.tool == CursorShit.tools.Scale:
		if event is InputEventMouseMotion:
			CursorShit.scale_factor.x+=-event.relative.x*Renderer.factor
			CursorShit.scale_factor.y+=event.relative.y*Renderer.factor
	
	if CursorShit.tool == CursorShit.tools.Rotate:
		if event is InputEventMouseMotion:
			CursorShit.angle+=event.relative.x/100
			
func move():
	if CursorShit.tool != CursorShit.tools.Move:
		return
	
	var highest = -Vector2.INF
	var lowest = Vector2.INF
	var m_pos = Vector2.ZERO
	for i in CursorShit.points_start_pos[0]:
		if highest.x < i.x:
			highest.x = i.x
		if highest.y < i.y:
			highest.y = i.y
		if lowest.x > i.x:
			lowest.x = i.x
		if lowest.y > i.y:
			lowest.y = i.y
	m_pos = (highest+lowest)/2
	
	if Renderer.pivots[Renderer.cur_layer-1] != Vector2.INF && !Renderer.pivot_locked:
		Renderer.pivots[Renderer.cur_layer-1] = (get_global_mouse_position()-CursorShit.move_factor)+CursorShit.move_offset+CursorShit.pivot_start_pos
		m_pos = CursorShit.pivot_start_pos
	var go_back = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	
	if go_back:
		Renderer.pivots[Renderer.cur_layer-1] = CursorShit.pivot_start_pos
	for i in CursorShit.points_start_pos[1]:
		if go_back:
			Renderer.points[i[0]][i[1]] = CursorShit.points_start_pos[0][i[2]]
			continue
			
		if Input.is_key_pressed(KEY_CTRL) && Input.is_key_pressed(KEY_SHIFT):
			Renderer.points[i[0]][i[1]]=(CursorShit.points_start_pos[0][i[2]]-m_pos)+Renderer.center
			if Renderer.pivots[Renderer.cur_layer-1] != Vector2.INF && !Renderer.pivot_locked:
				Renderer.pivots[Renderer.cur_layer-1] = Renderer.center
			if Renderer.pivot_locked:
				Renderer.points[i[0]][i[1]]=(CursorShit.points_start_pos[0][i[2]]-m_pos)+Renderer.pivots[Renderer.cur_layer-1]
			continue
		Renderer.points[i[0]][i[1]]=(get_global_mouse_position()-CursorShit.move_factor)+CursorShit.move_offset+CursorShit.points_start_pos[0][i[2]]
		if Input.is_key_pressed(KEY_CTRL):
			Renderer.points[i[0]][i[1]].y=CursorShit.points_start_pos[0][i[2]].y
			if Renderer.pivots[Renderer.cur_layer-1] != Vector2.INF && !Renderer.pivot_locked:
				Renderer.pivots[Renderer.cur_layer-1].y = CursorShit.pivot_start_pos.y
		elif Input.is_key_pressed(KEY_SHIFT):
			Renderer.points[i[0]][i[1]].x=CursorShit.points_start_pos[0][i[2]].x
			if Renderer.pivots[Renderer.cur_layer-1] != Vector2.INF && !Renderer.pivot_locked:
				Renderer.pivots[Renderer.cur_layer-1].x = CursorShit.pivot_start_pos.x
			
	if go_back:
		CursorShit.tool = CursorShit.tools.Selector
		CursorShit.change_cursor()
		
func rotate():
	if CursorShit.tool != CursorShit.tools.Rotate:
		return
	var highest = -Vector2.INF
	var lowest = Vector2.INF
	var m_pos = Vector2.ZERO
	for i in CursorShit.points_start_pos[0]:
		if highest.x < i.x:
			highest.x = i.x
		if highest.y < i.y:
			highest.y = i.y
		if lowest.x > i.x:
			lowest.x = i.x
		if lowest.y > i.y:
			lowest.y = i.y
	m_pos = (highest+lowest)/2
	if Renderer.pivots[Renderer.cur_layer-1] != Vector2.INF:
		m_pos = Renderer.pivots[Renderer.cur_layer-1]
	var go_back = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	for i in CursorShit.points_start_pos[1]:
		if go_back:
			Renderer.points[i[0]][i[1]] = CursorShit.points_start_pos[0][i[2]]
			continue
			
		var factor = CursorShit.points_start_pos[0][i[2]]-m_pos
		var _x = m_pos.x + (factor.x)*cos(CursorShit.angle) - (factor.y)*sin(CursorShit.angle)
		var _y = m_pos.y + (factor.x)*sin(CursorShit.angle) + (factor.y)*cos(CursorShit.angle)
		if Input.is_key_pressed(KEY_CTRL):
			Renderer.points[i[0]][i[1]].x=(CursorShit.points_start_pos[0][i[2]]).x
			Renderer.points[i[0]][i[1]].y = _y
		elif Input.is_key_pressed(KEY_SHIFT):
			Renderer.points[i[0]][i[1]].y=(CursorShit.points_start_pos[0][i[2]]).y
			Renderer.points[i[0]][i[1]].x = _x
		else:
			Renderer.points[i[0]][i[1]].x = _x
			Renderer.points[i[0]][i[1]].y = _y
			
	if go_back:
		CursorShit.tool = CursorShit.tools.Selector
		CursorShit.change_cursor()
	
func scale():
	if CursorShit.tool != CursorShit.tools.Scale:
		return
	var highest = -Vector2.INF
	var lowest = Vector2.INF
	var m_pos = Vector2.ZERO
	for i in CursorShit.points_start_pos[0]:
		if highest.x < i.x:
			highest.x = i.x
		if highest.y < i.y:
			highest.y = i.y
		if lowest.x > i.x:
			lowest.x = i.x
		if lowest.y > i.y:
			lowest.y = i.y
	m_pos = (highest+lowest)/2
	if Renderer.pivots[Renderer.cur_layer-1] != Vector2.INF:
		m_pos = Renderer.pivots[Renderer.cur_layer-1]
	var go_back = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)
	for i in CursorShit.points_start_pos[1]:
		if go_back:
			Renderer.points[i[0]][i[1]] = CursorShit.points_start_pos[0][i[2]]
			continue
			
		var factor = (m_pos-CursorShit.points_start_pos[0][i[2]])/100
		if Input.is_key_pressed(KEY_CTRL) && Input.is_key_pressed(KEY_SHIFT):
			Renderer.points[i[0]][i[1]] = ((CursorShit.scale_factor.x+CursorShit.scale_factor.y)*factor/2)+CursorShit.points_start_pos[0][i[2]]
			continue
		if Input.is_key_pressed(KEY_CTRL):
			Renderer.points[i[0]][i[1]].x=(CursorShit.points_start_pos[0][i[2]]).x
			Renderer.points[i[0]][i[1]].y=(CursorShit.scale_factor*factor/2+CursorShit.points_start_pos[0][i[2]]).y
		elif Input.is_key_pressed(KEY_SHIFT):
			Renderer.points[i[0]][i[1]].y=(CursorShit.points_start_pos[0][i[2]]).y
			Renderer.points[i[0]][i[1]].x=(CursorShit.scale_factor*factor+CursorShit.points_start_pos[0][i[2]]).x
		else:
			Renderer.points[i[0]][i[1]] = (CursorShit.scale_factor*factor*Renderer.factor)+CursorShit.points_start_pos[0][i[2]]
			
	if go_back:
		CursorShit.tool = CursorShit.tools.Selector
		CursorShit.change_cursor()

func guy():
	if CursorShit.tool != CursorShit.tools.Guy:
		return
	var c_pos = get_global_mouse_position()
	if Renderer.grid_size.x != 0:
		var offset = Renderer.center.x-(floor(Renderer.center.x/Renderer.grid_size.x)*Renderer.grid_size.x)
		c_pos.x = floor(c_pos.x/Renderer.grid_size.x)*Renderer.grid_size.x+offset-(Vector2(CursorShit.man.get_width(), CursorShit.man.get_height())/2).x
	if Renderer.grid_size.y != 0:
		var offset = Renderer.center.y-(floor(Renderer.center.y/Renderer.grid_size.y)*Renderer.grid_size.y)
		c_pos.y = floor(c_pos.y/Renderer.grid_size.y)*Renderer.grid_size.y+offset-(Vector2(CursorShit.man.get_width(), CursorShit.man.get_height())/2).y
		
	Renderer.guy_pos = c_pos-Renderer.position
	if Input.is_key_pressed(KEY_SHIFT):
		Renderer.guy_pos = Renderer.center-(Vector2(CursorShit.man.get_width(), CursorShit.man.get_height())/2)
	
func draw():
	if CursorShit.tool != CursorShit.tools.Draw:
		return
		
	if Renderer.visible_layers[Renderer.cur_layer-1] != true:
		return
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) && Renderer.selected_points[1].size() >= 2:
		var highest = -Vector2.INF
		var lowest = Vector2.INF
		var m_pos = Vector2.ZERO
		for i in Renderer.selected_points[0]:
			if highest.x < i.x:
				highest.x = i.x
			if highest.y < i.y:
				highest.y = i.y
			if lowest.x > i.x:
				lowest.x = i.x
			if lowest.y > i.y:
				lowest.y = i.y
		m_pos = (highest+lowest)/2
		Renderer.points[Renderer.cur_layer-1].push_back(m_pos)
		Renderer.selected_points = [[], []]
		Renderer.selected_points[0].push_back(Renderer.points[Renderer.cur_layer-1].back())
		Renderer.selected_points[1].push_back([Renderer.cur_layer-1,Renderer.points[Renderer.cur_layer-1].size()-1])
		CursorShit.tool = CursorShit.tools.Selector
		CursorShit.change_cursor()
		return
	
	Renderer.selected_points = [[], []]
	
	var c_pos = get_global_mouse_position()-Renderer.position
	if Renderer.grid_size.x != 0:
		var offset = Renderer.center.x-(floor(Renderer.center.x/Renderer.grid_size.x)*Renderer.grid_size.x)
		c_pos.x = floor(c_pos.x/Renderer.grid_size.x)*Renderer.grid_size.x+offset
	if Renderer.grid_size.y != 0:
		var offset = Renderer.center.y-(floor(Renderer.center.y/Renderer.grid_size.y)*Renderer.grid_size.y)
		c_pos.y = floor(c_pos.y/Renderer.grid_size.y)*Renderer.grid_size.y+offset
	
	var m_pos = (Renderer.center*2)-c_pos
	if CursorShit.mirror==1:
		m_pos.y = c_pos.y
	if CursorShit.mirror==2:
		m_pos.x = c_pos.x
		
	Renderer.points[Renderer.cur_layer-1].push_back(c_pos)
	
	if CursorShit.mirror<1:
		return
	Renderer.points[Renderer.cur_layer-1].push_front(m_pos)

func select():
	if CursorShit.tool != CursorShit.tools.Selector || !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) || !is_hovered():
		return
		
	queue_redraw()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) && selected_pos[0] == Vector2.ZERO:
		deselect = true
		selected_pos[0] = get_local_mouse_position()-Vector2.ONE*2
		selected_prev = Renderer.selected_points.duplicate(true)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && selected_pos[0] == Vector2.ZERO:
		deselect = false
		selected_pos[0] = get_local_mouse_position()-Vector2.ONE*2
		if !Input.is_key_pressed(KEY_SHIFT):
			Renderer.selected_points = [[], []]
	selected_pos[1] = get_local_mouse_position()
	
	if deselect:
		for i in Renderer.points.size():
			if Renderer.visible_layers[i] != true:
				continue
			for j in Renderer.points[i].size():
				var x0 = (Renderer.points[i][j].x+Renderer.position.x-selected_pos[0].x)*sign(selected_pos[1].x-selected_pos[0].x)>0
				var y0 = (Renderer.points[i][j].y+Renderer.position.y-65-selected_pos[0].y)*sign(selected_pos[1].y-selected_pos[0].y)>0
				var x = (Renderer.points[i][j].x+Renderer.position.x - selected_pos[1].x)*sign(selected_pos[0].x-selected_pos[1].x)>=0 && x0
				var y = (Renderer.points[i][j].y+Renderer.position.y-65 - selected_pos[1].y)*sign(selected_pos[0].y-selected_pos[1].y)>=0  && y0
				
				if [i,j] in Renderer.selected_points[1] && x && y:
					if Input.is_key_pressed(KEY_CTRL) && i != Renderer.cur_layer-1:
						continue
					Renderer.selected_points[0].erase(Renderer.points[i][j])
					Renderer.selected_points[1].erase([i,j])
				
				if not [i,j] in selected_prev[1] && not Renderer.points[i][j] in Renderer.selected_points[0] && x && y:
					if Input.is_key_pressed(KEY_CTRL) && i != Renderer.cur_layer-1:
						continue
					Renderer.selected_points[0].push_back(Renderer.points[i][j])
					Renderer.selected_points[1].push_back([i,j])
	else:
		for i in Renderer.points.size():
			if Renderer.visible_layers[i] != true:
				continue
			for j in Renderer.points[i].size():
				var x0 = (Renderer.points[i][j].x+Renderer.position.x-selected_pos[0].x)*sign(selected_pos[1].x-selected_pos[0].x)>0
				var y0 = (Renderer.points[i][j].y+Renderer.position.y-65-selected_pos[0].y)*sign(selected_pos[1].y-selected_pos[0].y)>0
				var x = (Renderer.points[i][j].x+Renderer.position.x - selected_pos[1].x)*sign(selected_pos[0].x-selected_pos[1].x)>=0 && x0
				var y = (Renderer.points[i][j].y+Renderer.position.y-65 - selected_pos[1].y)*sign(selected_pos[0].y-selected_pos[1].y)>=0  && y0
				
				if not [i,j] in Renderer.selected_points[1] && x && y:
					if Input.is_key_pressed(KEY_CTRL) && i != Renderer.cur_layer-1:
						continue
					Renderer.selected_points[0].push_back(Renderer.points[i][j])
					Renderer.selected_points[1].push_back([i,j])

func _draw() -> void:
	var r : Rect2 = Rect2(selected_pos[0],selected_pos[1]-selected_pos[0])
	var c = Color.BLUE
	c.a = 0.25
	
	draw_rect(r, c)


func _on_button_up() -> void:
	selected_pos = [Vector2.ZERO, Vector2.ZERO]
	queue_redraw()
	
	if CursorShit.tool != CursorShit.tools.Move && CursorShit.tool != CursorShit.tools.Rotate && CursorShit.tool != CursorShit.tools.Scale:
		return
		
	CursorShit.tool = CursorShit.tools.Selector
	CursorShit.change_cursor()
	
	var highest = -Vector2.INF
	var lowest = Vector2.INF
	var m_pos1 = Vector2.ZERO
	for i in Renderer.selected_points[1]:
		if highest.x < Renderer.points[i[0]][i[1]].x:
			highest.x = Renderer.points[i[0]][i[1]].x
		if highest.y < Renderer.points[i[0]][i[1]].y:
			highest.y = Renderer.points[i[0]][i[1]].y
		if lowest.x > Renderer.points[i[0]][i[1]].x:
			lowest.x = Renderer.points[i[0]][i[1]].x
		if lowest.y > Renderer.points[i[0]][i[1]].y:
			lowest.y = Renderer.points[i[0]][i[1]].y
	m_pos1 = (highest+lowest)/2
	
	for i in Renderer.selected_points[1]:
		if Renderer.grid_size.x != 0:
			var offset = Renderer.center.x-(floor(Renderer.center.x/Renderer.grid_size.x)*Renderer.grid_size.x)
			Renderer.points[i[0]][i[1]].x = floor(Renderer.points[i[0]][i[1]].x/Renderer.grid_size.x)*Renderer.grid_size.x+offset
		if Renderer.grid_size.y != 0:
			var offset = Renderer.center.y-(floor(Renderer.center.y/Renderer.grid_size.y)*Renderer.grid_size.y)
			Renderer.points[i[0]][i[1]].y = floor(Renderer.points[i[0]][i[1]].y/Renderer.grid_size.y)*Renderer.grid_size.y+offset
	
	for i in Renderer.selected_points[0].size():
		Renderer.selected_points[0][i] = Renderer.points[Renderer.selected_points[1][i][0]][Renderer.selected_points[1][i][1]]
	
	highest = -Vector2.INF
	lowest = Vector2.INF
	var m_pos2 = Vector2.ZERO
	for i in Renderer.selected_points[1]:
		if highest.x < Renderer.points[i[0]][i[1]].x:
			highest.x = Renderer.points[i[0]][i[1]].x
		if highest.y < Renderer.points[i[0]][i[1]].y:
			highest.y = Renderer.points[i[0]][i[1]].y
		if lowest.x > Renderer.points[i[0]][i[1]].x:
			lowest.x = Renderer.points[i[0]][i[1]].x
		if lowest.y > Renderer.points[i[0]][i[1]].y:
			lowest.y = Renderer.points[i[0]][i[1]].y
	m_pos2 = (highest+lowest)/2
	
	if Renderer.pivots[Renderer.cur_layer-1] != Vector2.INF || Renderer.pivot_locked:
		return
		
	if Renderer.selected_points[1].size()>0:
		Renderer.pivots[Renderer.cur_layer-1]+=m_pos2-m_pos1
	if Renderer.selected_points[1].size()==0:
		if Renderer.grid_size.x != 0:
			var offset = Renderer.center.x-(floor(Renderer.center.x/Renderer.grid_size.x)*Renderer.grid_size.x)
			Renderer.pivots[Renderer.cur_layer-1].x = floor(Renderer.pivots[Renderer.cur_layer-1].x/Renderer.grid_size.x)*Renderer.grid_size.x+offset
		if Renderer.grid_size.y != 0:
			var offset = Renderer.center.y-(floor(Renderer.center.y/Renderer.grid_size.y)*Renderer.grid_size.y)
			Renderer.pivots[Renderer.cur_layer-1].y = floor(Renderer.pivots[Renderer.cur_layer-1].y/Renderer.grid_size.y)*Renderer.grid_size.y+offset

func _on_focus_entered() -> void:
	release_focus()
