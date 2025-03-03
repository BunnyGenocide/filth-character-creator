extends TextEdit

func _input(ev):
	if Input.is_key_pressed(KEY_ENTER):
		release_focus()
