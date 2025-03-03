extends HBoxContainer


var buttons : Array[TextureButton]
func _ready() -> void:
	for i in get_children():
		if i is TextureButton:
			buttons.push_back(i)
	
	
func _input(event):
	if !Renderer.can_shortcut:
		return
		
	if Input.is_key_pressed(KEY_1):
		buttons[0].press()
	if Input.is_key_pressed(KEY_2):
		buttons[1].press()
	if Input.is_key_pressed(KEY_3):
		buttons[2].press()
	if Input.is_key_pressed(KEY_4):
		buttons[3].press()
	if Input.is_key_pressed(KEY_5):
		buttons[4].press()
	if Input.is_key_pressed(KEY_6):
		buttons[5].press()
	if Input.is_key_pressed(KEY_7):
		buttons[6].press()
	if Input.is_key_pressed(KEY_8):
		buttons[7].press()
	if Input.is_key_pressed(KEY_9):
		buttons[8].press()
	if Input.is_key_pressed(KEY_0):
		buttons[9].press()

func a(button):
	print(button.name, " was pressed")
