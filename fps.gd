extends TextEdit

func _ready() -> void:
	text = ""
	
func _input(ev):
	if Input.is_key_pressed(KEY_ENTER):
		release_focus()


func _on_focus_exited() -> void:
	var number = int(text)
	
	if number < 1:
		number = 1
	
	text = str(number)
	Renderer.fps=number
	
	Renderer.can_shortcut=true
	

func _on_focus_entered() -> void:
	Renderer.can_shortcut=false


func _on_visibility_changed() -> void:
	text = str(Renderer.fps)
