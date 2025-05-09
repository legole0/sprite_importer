extends Control
class_name ImporterTab

@export var importer_script:GDScript
var importer:Importer

@export_group("References")
@export var sprite_path:LineEdit
@export var atlas_path:LineEdit
@export var fps:SpinBox
@export var check_dupped:CheckBox
@export var loop:CheckBox
@export var compress_output:CheckBox
@export var anim_tree:ImporterAnimationTree

var focused_line_edit:NodePath

func _enter_tree() -> void:
	if importer_script == null:
		return
	importer = (importer_script).new() as Importer
	
	if sprite_path != null or atlas_path != null and importer.needs_atlas_path():
		sprite_path.connect("text_changed", autofill_atlas_path)
		sprite_path.connect("text_submitted", autofill_atlas_path)

func on_quick_import() -> void:
	print("Importing Sprite...")
	
	var sprite_list:Array[String] = []
	var path_is_directory:bool = sprite_path.text.get_extension().is_empty()
	
	if path_is_directory:
		if !importer.should_check_dir():
			printerr("Provided path is a directory.")
			return
		
		print("Provided path is a directory. Converting every sprite in it...")
		
		var folder_sprites:PackedStringArray = DirAccess.get_files_at(sprite_path.text);
		
		for sprite:String in folder_sprites:
			sprite_list.append(sprite_path.text+sprite)
			print("Found sprite: " + sprite_path.text+sprite)
	else:
		sprite_list.append(sprite_path.text)
	
	if sprite_list.is_empty():
		printerr("No sprites found with the given path.")
		return
	
	for sprite:String in sprite_list:
		if !ResourceLoader.exists(sprite):
			printerr("Path \""+sprite+"\" doesn\'t appear to be a valid sprite type.")
			continue
		
		var texture:Texture2D = load(sprite)
		var atlas:String = sprite.get_basename()+importer.get_atlas_extension() if atlas_path.text.is_empty() else atlas_path.text
		
		print("Sprite Path: "+sprite+"\nAtlas Path: "+atlas)
		importer.convert_sprite(texture,atlas,check_dupped.button_pressed,loop.button_pressed,fps.value,compress_output.button_pressed)


func _make_file_dialog() -> ConfirmationDialog:
	if Engine.is_editor_hint():
		var file_dialog:EditorFileDialog = EditorFileDialog.new()
		file_dialog.title = "Select a spritesheet"
		file_dialog.file_mode = EditorFileDialog.FileMode.FILE_MODE_OPEN_ANY
		file_dialog.size = Vector2(768, 768)
		file_dialog.initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		file_dialog.filters = ["*.png", "*.webp", "*.xml"]
		file_dialog.connect("dir_selected",dir_selected)
		file_dialog.connect("file_selected",file_selected)
		return file_dialog
	
	var file_dialog:FileDialog = FileDialog.new()
	file_dialog.title = "Select a spritesheet"
	file_dialog.file_mode = FileDialog.FileMode.FILE_MODE_OPEN_ANY
	file_dialog.size = Vector2(768,512)
	file_dialog.initial_position = Window.WindowInitialPosition.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	file_dialog.filters = ["*.png", "*.webp", "*.xml"]
	file_dialog.connect("dir_selected",dir_selected)
	file_dialog.connect("file_selected",file_selected)
	return file_dialog

func _exit_tree() -> void:
	#if file_dialog != null:
		#file_dialog.disconnect("dir_selected",dir_selected)
		#file_dialog.disconnect("file_selected",file_selected)
	
	if sprite_path != null and atlas_path != null and importer.needs_atlas_path():
		sprite_path.disconnect("text_changed", autofill_atlas_path)
		sprite_path.disconnect("text_submitted", autofill_atlas_path)

func folder_button(button_node_path:NodePath, _focused_line_edit:NodePath) -> void:
	#reminder for myself
	#using nodepaths is relative so this shit wont work, ill have to use manual paths or something
	#imma play fortnite fuck this
	focused_line_edit = _focused_line_edit
	
	var file_dialog:ConfirmationDialog = _make_file_dialog()
	add_child(file_dialog)
	file_dialog.popup_centered()

func file_selected(path:String) -> void:
	var is_sprite_path = true #temporary
	
	if is_sprite_path:
		var texture_extensions:PackedStringArray = importer.get_texture_extensions()
		if !texture_extensions.has(path.get_extension()):
			var found_new_extension:bool = false
			for tex_extension:String in texture_extensions:
				if FileAccess.file_exists(path.get_basename() + tex_extension):
					found_new_extension = true
					path = path.get_basename() + tex_extension
					break
		
		autofill_atlas_path(path)
	
	var line_edit = get_node(focused_line_edit)
	if line_edit is LineEdit and line_edit != null:
		line_edit.text = path;

func dir_selected(path:String) -> void:
	if !path.ends_with("/"):
		path += "/"
	
	var line_edit = get_node(focused_line_edit)
	if line_edit is LineEdit and line_edit != null:
		line_edit.text = path;
	autofill_atlas_path(path)

func autofill_atlas_path(new_path:String):
	if importer.get_texture_extensions().has("."+new_path.get_extension()):
		var atlas_path_predict:String = new_path.get_basename() + importer.get_atlas_extension()
		
		if FileAccess.file_exists(atlas_path_predict):
			atlas_path.text = atlas_path_predict

func add_to_tree():
	pass
