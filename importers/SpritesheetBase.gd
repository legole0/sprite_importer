extends Node
class_name SpritesheetBase

@export var atlas_format:String
@export var sprite_path:LineEdit
@export var fps:SpinBox
@export var loop:CheckBox
@export var check_dupped:CheckBox
@export var compress_output:CheckBox
var file_dialog

func on_button_press() -> void:
	print("Importing Sprite...")
	
	var sprite_list:Array[String] = []
	var path_is_directory:bool = sprite_path.text.ends_with("/") or (!sprite_path.text.ends_with(".png") and !sprite_path.text.ends_with(".webp")) and !sprite_path.text.ends_with(atlas_format)

	if path_is_directory:
		var folder_sprites:Array[String] = ImportUtils.list_directory(sprite_path.text);
		for sprite:String in folder_sprites:
			if (sprite.ends_with(".png") or sprite.ends_with(".webp")) and FileAccess.file_exists(sprite_path.text + sprite.get_basename() + atlas_format):
				sprite_list.append(sprite_path.text+sprite)
	else:
		sprite_list.append(sprite_path.text)

	for sprite:String in sprite_list:
		if ResourceLoader.exists(sprite):
			var texture:Texture2D = load(sprite)
			var atlas:String = sprite.get_basename()+atlas_format
			
			print("Sprite Path: "+sprite+"\nAtlas Path: "+atlas)
			convert_sprite(texture,atlas)
		else:
			printerr("No sprite found with the given path: "+sprite)

func _enter_tree() -> void:
	file_dialog = EditorFileDialog.new() if Engine.is_editor_hint() else FileDialog.new()
	file_dialog.title = "Select a spritesheet"
	file_dialog.file_mode = EditorFileDialog.FileMode.FILE_MODE_OPEN_ANY
	file_dialog.size = Vector2(768, 768) if Engine.is_editor_hint() else Vector2(768,512)
	file_dialog.initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	file_dialog.filters = ["*.png", "*.webp", "*.xml"]
	file_dialog.connect("dir_selected",dir_selected)
	file_dialog.connect("file_selected",file_selected)
	add_child(file_dialog)

func _exit_tree() -> void:
	file_dialog.disconnect("dir_selected",dir_selected)
	file_dialog.disconnect("file_selected",file_selected)

func folder_button() -> void:
	file_dialog.popup_centered()

func file_selected(path:String) -> void:
	sprite_path.text = path;

func dir_selected(path:String) -> void:
	if !path.ends_with("/"):
		path += "/"
	sprite_path.text = path;

func convert_sprite(tex:Texture2D,atlas_path:String):
	pass
