extends TextEdit

@export var x_type = true

func _ready() -> void:
	connect("focus_entered", _on_focus_entered)
	connect("focus_exited", _on_focus_exited)
func _input(ev):
	if Input.is_key_pressed(KEY_ENTER):
		release_focus()
		
func _on_focus_exited() -> void:
	Renderer.can_shortcut=true
	var number = float(text)
	if number < 0:
		number = 0
	text = str(number)
	if x_type:
		Renderer.grid_size.x=number
		return
	Renderer.grid_size.y=number

func _on_focus_entered() -> void:
	Renderer.can_shortcut=false
