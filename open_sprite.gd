extends Node

@onready var dialog = FileDialog.new()
func _ready() -> void:
	dialog.visible = true
	dialog.access = 2
	dialog.file_mode = 0
	dialog.filters = PackedStringArray(["*.png"])
	var username = "Default"
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
	dialog.current_dir = "C:/Users/" + username + "/Desktop"
	dialog.size = Vector2(750,500)
	dialog.position = Vector2(100,100)
	add_child(dialog)
	
	dialog.connect("file_selected", _on_file_dialog_file_selected)

func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	var t = PortableCompressedTexture2D.new()
	t.create_from_image(image, PortableCompressedTexture2D.COMPRESSION_MODE_LOSSLESS)
	CursorShit.man = t
	CursorShit.tool = CursorShit.tools.Guy
	CursorShit.change_cursor()
	
	queue_free()
