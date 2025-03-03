extends Node2D

var compiling = false

var center: Vector2
var guy_pos: Vector2 = Vector2(-100,0)
@onready var view = get_viewport_rect()

var can_shortcut = true
var pivot_locked = false

var frames = []
var visible_layers = []
var points = []
var pivots = []
var copied_points = []
var selected_points = [[], []]
var cur_layer = 1
var cur_frame = 1
var elapsed_time = 0
var animate = false
var fps = 1

var grid_size = Vector2(0,0)

var prev_frames = [[]]
var undone_frames = [[]]
var prev_states = []
var undone_states = []
var prev_pivot = []
var undone_pivot = []

var hide_points = false
var onion_skin = true
var mode = []
var color = []

var factor = 1

func reset():
	frames = []
	visible_layers = []
	points = []
	pivots = []
	copied_points = []
	selected_points = [[], []]
	cur_layer = 1
	cur_frame = 1
	elapsed_time = 0
	animate = false
	fps = 1

	grid_size = Vector2(0,0)
	
	prev_frames = [[]]
	undone_frames = [[]]
	prev_states = []
	undone_states = []
	prev_pivot = []
	undone_pivot = []

	mode = []
	color = []
	
	for i in 10:
		mode.push_back(0)
		visible_layers.push_back(true)
		pivots.push_back(Vector2.INF)
		points.push_back([])
		prev_pivot.push_back([pivots[i]])
		undone_pivot.push_back([])
		color.push_back(Color.WHITE)
	
	var cur = []
	for i in points:
		cur.push_back(i.duplicate())
	
	frames.push_back(cur.duplicate())
func _ready() -> void:
	center = view.get_center()
	
	for i in 10:
		mode.push_back(0)
		visible_layers.push_back(true)
		pivots.push_back(Vector2.INF)
		points.push_back([])
		prev_pivot.push_back([pivots[i]])
		undone_pivot.push_back([])
		color.push_back(Color.WHITE)
	
	var cur = []
	for i in points:
		cur.push_back(i.duplicate())
	
	frames.push_back(cur.duplicate())
	
func _process(delta: float) -> void:
	queue_redraw()
	
	if !can_shortcut:
		return
	
	var mul = 2
	
	if Input.is_key_pressed(KEY_SHIFT):
		mul = 10
	if Input.is_key_pressed(KEY_CTRL):
		mul = 1
	
	if Input.is_key_pressed(KEY_A):
		position.x+=delta*50*mul
		CursorShit.move_offset.x-=delta*50*mul
	if Input.is_key_pressed(KEY_D):
		position.x-=delta*50*mul
		CursorShit.move_offset.x+=delta*50*mul
	if Input.is_key_pressed(KEY_S):
		position.y-=delta*50*mul
		CursorShit.move_offset.y+=delta*50*mul
	if Input.is_key_pressed(KEY_W):
		position.y+=delta*50*mul
		CursorShit.move_offset.y-=delta*50*mul
				
	if (CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate || CursorShit.tool == CursorShit.tools.Scale):
		return
	
	#idk why the ctrl z code works
	#it has to be written like this for some reason
	#when i push an array into another it actually creates a reference to the array inside(i think?)
	#i hate this language, kill me
	var cur = []
	for i in points:
		cur.push_back(i.duplicate())	
	if !points.is_empty() && prev_states.is_empty():
		prev_states.push_back(cur.duplicate())
	if !prev_states.is_empty() && !compare(prev_states.back(), points) && !is_pressed():
		undone_states = []
		undone_pivot[cur_layer-1] = []
		prev_states.push_back(cur.duplicate())
		prev_pivot[cur_layer-1].push_back(pivots[cur_layer-1])
	
	if prev_pivot[cur_layer-1].back() != pivots[cur_layer-1] && !is_pressed():
		undone_states = []
		undone_pivot[cur_layer-1] = []
		prev_states.push_back(cur.duplicate())
		prev_pivot[cur_layer-1].push_back(pivots[cur_layer-1])
		
func _physics_process(delta: float) -> void:
	if !animate || (CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate || CursorShit.tool == CursorShit.tools.Scale):
		return
	
	elapsed_time+=delta
		
	var move_frame = false
	
	var max_time=1.0/fps
	
	while elapsed_time>=max_time:
		elapsed_time-=max_time
		move_frame=true
	if move_frame:
		if cur_frame==frames.size():
			change_frame(-frames.size()+1)
			return
			
		change_frame(1)
		
func is_pressed():
	return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) || Input.is_key_pressed(KEY_UP) || Input.is_key_pressed(KEY_DOWN) || Input.is_key_pressed(KEY_LEFT) || Input.is_key_pressed(KEY_RIGHT)

func compare(prev, cur):
	var val = true
	for i in cur.size():
		if cur[i].hash() != prev[i].hash():
			val = false
	return val

func save_frame():
	var cur = []
	for i in points:
		cur.push_back(i.duplicate())
		prev_states.back().push_back([])
	frames[cur_frame-1] = cur.duplicate()
	
func change_frame(dir):
	selected_points = [[], []]
	var cur = []
	
	for i in frames.size():
		if !prev_frames[i]:
			prev_frames.push_back([])
			undone_frames.push_back([])
	
	prev_frames[cur_frame-1] = prev_states.duplicate(true)
	undone_frames[cur_frame-1] = undone_states.duplicate(true)
	
	for i in points:
		cur.push_back(i.duplicate())
	frames[cur_frame-1] = cur.duplicate()
	
	cur_frame+=dir
	cur_frame = clamp(cur_frame,1,frames.size())
	
	prev_states=prev_frames[cur_frame-1].duplicate(true)
	undone_states=undone_frames[cur_frame-1].duplicate(true)

	for i in points.size():
		points[i] = frames[cur_frame-1][i].duplicate()
		
func add_frame():
	var cur = []
	for i in points:
		cur.push_back(i.duplicate())
		
	frames.insert(cur_frame,cur.duplicate())
	prev_frames.insert(cur_frame,prev_states.duplicate(true))
	undone_frames.insert(cur_frame,undone_states.duplicate(true))
	
	change_frame(1)

func remove_frame():
	if cur_frame == 1:
		if frames.size()>1:
			change_frame(1)
			frames.pop_at(cur_frame-1)
			prev_frames.pop_at(cur_frame-1)
			undone_frames.pop_at(cur_frame-1)
			cur_frame-=1
		return
	change_frame(-1)
	prev_frames.pop_at(cur_frame)
	undone_frames.pop_at(cur_frame)
	frames.pop_at(cur_frame)

func sort_ascending(a, b):
	if a[1] < b[1]:
		return true
	return false

func sort_decending(a, b):
	if a[1] < b[1]:
		return false
	return true
	
func _input(ev):
	if Input.is_key_pressed(KEY_UP):
		cur_layer+=1
	if Input.is_key_pressed(KEY_DOWN):
		cur_layer-=1
	cur_layer=clamp(cur_layer,1,10)
	
	if Input.is_key_pressed(KEY_CTRL) && !(CursorShit.tool == CursorShit.tools.Scale || CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate) && Input.is_key_pressed(KEY_C):
		copied_points = []
		for i in selected_points[0].size():
			copied_points.push_back([selected_points[0][i], selected_points[1][i][1]])
	
	if Input.is_key_pressed(KEY_CTRL) && !(CursorShit.tool == CursorShit.tools.Scale || CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate) && Input.is_key_pressed(KEY_V):
		if copied_points == []:
			return
		selected_points = [[], []]
		copied_points.sort_custom(sort_ascending)
		
		for i in copied_points:
			points[cur_layer-1].push_back(i[0])
			Renderer.selected_points[0].push_back(points[cur_layer-1].back())
			Renderer.selected_points[1].push_back([cur_layer-1,points[cur_layer-1].size()-1])
		
		CursorShit.tool = CursorShit.tools.Move
		CursorShit.change_cursor()
	
	if Input.is_key_pressed(KEY_RIGHT) && frames.size()!=cur_frame && Input.is_key_pressed(KEY_SHIFT):
		var jump = 1
		if cur_frame != 1:
			jump=2
		
		frames.insert(cur_frame+1,frames[cur_frame-1].duplicate())
		remove_frame()
		change_frame(jump)
		return
	if Input.is_key_pressed(KEY_LEFT) && cur_frame!= 1 && Input.is_key_pressed(KEY_SHIFT):
		var jump = 1
		if cur_frame == 2:
			jump=0
			
		frames.insert(cur_frame,frames[cur_frame-2].duplicate())
		change_frame(-1)
		remove_frame()
		change_frame(jump)
		return
	
	if Input.is_key_pressed(KEY_RIGHT):
		change_frame(1)
	if Input.is_key_pressed(KEY_LEFT):
		change_frame(-1)
		
	if Input.is_key_pressed(KEY_INSERT):
		add_frame()
	if Input.is_key_pressed(KEY_SHIFT) && Input.is_key_pressed(KEY_DELETE):
		remove_frame()
		
	if Input.is_key_pressed(KEY_PERIOD) && !(CursorShit.tool == CursorShit.tools.Scale || CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate):
		for i in selected_points[1]:
			if i[1] >= points[i[0]].size()-1:
				return
		
		selected_points[1].sort_custom(sort_decending)
		for i in selected_points[1]:
			var pos = points[i[0]][i[1]]
			if i[1]+1 == points[i[0]].size()-1:
				points[i[0]].push_back(pos)
			else:
				points[i[0]].insert(i[1]+2, pos)
			points[i[0]].pop_at(i[1])
			i[1]+=1
			
	if Input.is_key_pressed(KEY_COMMA) && !(CursorShit.tool == CursorShit.tools.Scale || CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate):
		for i in selected_points[1]:
			if i[1] <= 0:
				return
		
		selected_points[1].sort_custom(sort_ascending)
		for i in selected_points[1]:
			var pos = points[i[0]][i[1]]
			points[i[0]].pop_at(i[1])
			points[i[0]].insert(i[1]-1, pos)
			i[1]-=1
		
	if Input.is_key_pressed(KEY_DELETE):
		var fuck = []
		for i in 10:
			fuck.push_back([])
		for j in points.size():
			for i in points[j].size():
				if not [j,i] in selected_points[1]:
					fuck[j].push_back(points[j][i])
		
		for i in points.size():
			points[i] = fuck[i].duplicate()
			
		CursorShit.tool = CursorShit.tools.Selector
		CursorShit.change_cursor()
		Renderer.selected_points = [[], []]
	
	if Input.is_key_pressed(KEY_Y) && Input.is_key_pressed(KEY_CTRL) && !(CursorShit.tool == CursorShit.tools.Scale || CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate):
		if !undone_pivot[cur_layer-1].is_empty():
			pivots[cur_layer-1] = undone_pivot[cur_layer-1].back()
			prev_pivot[cur_layer-1].push_back(undone_pivot[cur_layer-1].back())
			undone_pivot[cur_layer-1].pop_back()
			
		if undone_states.is_empty():
			return
		Renderer.selected_points = [[], []]
		
		for i in points.size():
			points[i] = undone_states.back()[i].duplicate()
		
		prev_states.push_back(undone_states.back().duplicate())
		undone_states.pop_back()
	if Input.is_key_pressed(KEY_Z) && Input.is_key_pressed(KEY_CTRL) && !(CursorShit.tool == CursorShit.tools.Scale || CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate):
		if prev_pivot[cur_layer-1].size() != 1:
			undone_pivot[cur_layer-1].push_back(prev_pivot[cur_layer-1].back())
			prev_pivot[cur_layer-1].pop_back()
			pivots[cur_layer-1] = prev_pivot[cur_layer-1].back()
		
		if prev_states.size() == 1:
			return
		Renderer.selected_points = [[], []]
		
		undone_states.push_back(prev_states.back().duplicate())
		prev_states.pop_back()

		for i in points.size():
			points[i] = prev_states.back()[i].duplicate()

func grid_draw():
	if compiling:
		return
		
	var i = center.x-position.x-(view.size.x/2)
	while i <= center.x-position.x+(view.size.x/2):
		if grid_size.x == 0:
			break
		var offset = center.x-(floor(center.x/grid_size.x)*grid_size.x)
		var a = floor(i/grid_size.x)*grid_size.x+offset
		draw_line(Vector2(a,center.y-(view.size.y/2)-position.y), Vector2(a,center.y+(view.size.y/2)-position.y), Color.DARK_GOLDENROD*0.5)
		i+=grid_size.x
	
	i = center.y-position.y-(view.size.y/2)
	while i <= center.y-position.y+(view.size.y/2):
		if grid_size.y == 0:
			break
		var offset = center.y-(floor(center.y/grid_size.y)*grid_size.y)
		var a = floor(i/grid_size.y)*grid_size.y+offset
		draw_line(Vector2(-position.x,a), Vector2(view.size.x-position.x,a), Color.DARK_MAGENTA*0.5)
		i+=grid_size.y
func _draw() -> void:
	grid_draw()
	
	if !compiling:
		draw_texture(CursorShit.man,guy_pos, Color.DIM_GRAY)
	
	
	if cur_frame > 1 && onion_skin && !compiling:
		for j in frames[cur_frame-2].size():
			if visible_layers[j] != true:
				continue
			for i in frames[cur_frame-2][j].size():
				if mode[j] == 0:
					if i>0:
						draw_line(frames[cur_frame-2][j][i-1], frames[cur_frame-2][j][i], Color.DARK_SLATE_GRAY * 0.5, factor)
						draw_circle(frames[cur_frame-2][j][i-1],0.5*factor,Color.DARK_SLATE_GRAY* 0.5,true)
					if i == frames[cur_frame-2][j].size()-1:
						draw_line(frames[cur_frame-2][j][i], frames[cur_frame-2][j][0], Color.DARK_SLATE_GRAY* 0.5, factor)
						draw_circle(frames[cur_frame-2][j][i],0.5*factor,Color.DARK_SLATE_GRAY* 0.5,true)
				elif mode[j] == 2:
					draw_polygon(frames[cur_frame-2][j], [Color.DARK_SLATE_GRAY* 0.5])
				else:
					if i>0 && i%2==1:
						draw_line(frames[cur_frame-2][j][i-1], frames[cur_frame-2][j][i], Color.DARK_SLATE_GRAY* 0.5, factor)
						draw_circle(frames[cur_frame-2][j][i-1],0.5*factor,Color.DARK_SLATE_GRAY* 0.5,true)
						draw_circle(frames[cur_frame-2][j][i],0.5*factor,Color.DARK_SLATE_GRAY* 0.5,true)
	if cur_frame < frames.size() && onion_skin && !compiling:
		for j in frames[cur_frame].size():
			if visible_layers[j] != true:
				continue
			for i in frames[cur_frame][j].size():
				if mode[j] == 0:
					if i>0:
						draw_line(frames[cur_frame][j][i-1], frames[cur_frame][j][i], Color.CORAL* 0.5, factor)
						draw_circle(frames[cur_frame][j][i-1],0.5*factor,Color.CORAL* 0.5,true)
					if i == frames[cur_frame][j].size()-1:
						draw_line(frames[cur_frame][j][i], frames[cur_frame][j][0], Color.CORAL* 0.5, factor)
						draw_circle(frames[cur_frame][j][i],0.5*factor,Color.CORAL* 0.5,true)
				elif mode[j] == 2:
					draw_polygon(frames[cur_frame][j], [Color.CORAL* 0.5])
				else:
					if i>0 && i%2==1:
						draw_line(frames[cur_frame][j][i-1], frames[cur_frame][j][i], Color.CORAL* 0.5, factor)
						draw_circle(frames[cur_frame][j][i-1],0.5*factor,Color.CORAL* 0.5,true)
						draw_circle(frames[cur_frame][j][i],0.5*factor,Color.CORAL* 0.5,true)
	
	if !hide_points || compiling:
		draw_line(center+(Vector2.UP*5),center-(Vector2.UP*5), Color.CHARTREUSE)
		draw_line(center+(Vector2.LEFT*5),center-(Vector2.LEFT*5), Color.CHARTREUSE)
		draw_circle(guy_pos+(Vector2(CursorShit.man.get_width(), CursorShit.man.get_height())/2),2,Color.MEDIUM_VIOLET_RED,true)
		draw_circle(center,2,Color.RED,true)
	
	var fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely = [-Vector2.INF, Vector2.INF]
		
	for j in points.size():
		if visible_layers[j] != true:
			continue
		
		var point_c = (color[j]/2).inverted()
		point_c.a = 1
		if j != cur_layer-1:
			point_c = Color.BROWN
			
		if mode[j] == 2:
			var p = PackedVector2Array(points[j])
			draw_polygon(p, [color[j]])
		for i in points[j].size():
			if mode[j] == 0:
				if i>0:
					draw_line(points[j][i-1], points[j][i], color[j], factor)
					draw_circle(points[j][i-1],0.5*factor,color[j],true)
				if i == points[j].size()-1:
					draw_line(points[j][i], points[j][0], color[j], factor)
					draw_circle(points[j][i],0.5*factor,color[j],true)
			elif mode[j] == 2:
				break
			else:
				if i>0 && i%2==1:
					draw_line(points[j][i-1], points[j][i], color[j], factor)
					draw_circle(points[j][i-1],0.5*factor,color[j],true)
					draw_circle(points[j][i],0.5*factor,color[j],true)
			
		if hide_points || compiling:
			continue
		for i in points[j].size():
			if [j,i] in selected_points[1]:
				var highest = fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely[0]
				var lowest = fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely[1]
				var p = points[j][i]
				if CursorShit.tool == CursorShit.tools.Rotate || CursorShit.tool == CursorShit.tools.Scale:
					for h in CursorShit.points_start_pos[1]:
						if [h[0], h[1]] == [j,i]:
							p = CursorShit.points_start_pos[0][h[2]]
							break
				
				if p.x > highest.x:
					fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely[0].x = p.x
				if p.y > highest.y:
					fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely[0].y = p.y
				if p.x < lowest.x:
					fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely[1].x = p.x
				if p.y < lowest.y:
					fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely[1].y = p.y
				
				draw_circle(points[j][i],5,color[j]/2,true)
				draw_circle(points[j][i],2.5,Color.WHITE/2,true)
			draw_circle(points[j][i],0.75,point_c,true)
	
	if compiling:
		draw_line(center+(Vector2.UP*5),center-(Vector2.UP*5), Color.CHARTREUSE)
		draw_line(center+(Vector2.LEFT*5),center-(Vector2.LEFT*5), Color.CHARTREUSE)
		draw_circle(center,2,Color.RED,true)
	if compiling:
		return
	if selected_points[1].size()>1 || pivots[cur_layer-1] != Vector2.INF:
		var highest = fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely[0]
		var lowest = fun_fact_i_cant_just_take_the_averages_of_all_the_selected_points_because_you_can_have_a_bunch_in_the_same_place_and_fuck_the_pivot_point_completely[1]
		
		var m_pos = (highest+lowest)/2
		if pivots[cur_layer-1] != Vector2.INF:
			m_pos = pivots[cur_layer-1]
		draw_circle(m_pos,2,Color.CHARTREUSE,true)
		draw_line(m_pos+(Vector2.UP*5),m_pos-(Vector2.UP*5), Color.RED)
		draw_line(m_pos+(Vector2.LEFT*5),m_pos-(Vector2.LEFT*5), Color.RED)
		
	if !hide_points || compiling:
		if (CursorShit.tool == CursorShit.tools.Move || CursorShit.tool == CursorShit.tools.Rotate || CursorShit.tool == CursorShit.tools.Scale) && (grid_size.x != 0 || grid_size.y != 0):
			for i in selected_points[1]:
				var p_pos = points[i[0]][i[1]]
				if grid_size.x != 0:
					var offset = center.x-(floor(center.x/grid_size.x)*grid_size.x)
					p_pos.x = floor(p_pos.x/grid_size.x)*grid_size.x+offset
				if grid_size.y != 0:
					var offset = center.y-(floor(center.y/grid_size.y)*grid_size.y)
					p_pos.y = floor(p_pos.y/grid_size.y)*grid_size.y+offset
				draw_circle(p_pos,1,Color.MEDIUM_SLATE_BLUE,true)
	var c_pos = get_global_mouse_position()-position
	if grid_size.x != 0:
		var offset = center.x-(floor(center.x/grid_size.x)*grid_size.x)
		c_pos.x = floor(c_pos.x/grid_size.x)*grid_size.x+offset
	if grid_size.y != 0:
		var offset = center.y-(floor(center.y/grid_size.y)*grid_size.y)
		c_pos.y = floor(c_pos.y/grid_size.y)*grid_size.y+offset
	if CursorShit.tool == CursorShit.tools.Draw:
		draw_circle(c_pos,1,color[cur_layer-1],true)
