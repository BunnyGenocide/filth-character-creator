extends Window

@onready var container = $Camera2D/AnimationContainer
func save_data(data):
	var children = container.get_children()
	for i in children.size():
		if i == container.cur_animation:
			children[i].data = data
			children[i].play()
			children[i].play()
			return


func _on_close_requested() -> void:
	Renderer.compiling = false
	visible = false
	var ba = get_tree().get_nodes_in_group("build_area")[0]
	ba.visible = true
	Renderer.can_shortcut=true
	Renderer.animate=false


func _on_focus_exited() -> void:
	Renderer.can_shortcut=true


func _on_focus_entered() -> void:
	Renderer.can_shortcut=false
