@tool
extends Control
class_name ImporterTab

@export var importer_script:GDScript
var importer:SpriteImporter

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
	importer = (importer_script).new() as SpriteImporter
	name = importer.get_format_name()
	
	if sprite_path != null or atlas_path != null and importer.needs_atlas_path():
		sprite_path.connect("text_changed", autofill_atlas_path)
		sprite_path.connect("text_submitted", autofill_atlas_path)
		
		atlas_path.connect("text_changed", autofill_sprite_path)
		atlas_path.connect("text_submitted", autofill_sprite_path)

func process_sprite() -> Array[ImporterSpriteData]:
	var sprite_list:Array[ImporterSpriteData]
	var sprite_name_list:PackedStringArray
	var path_is_directory:bool = sprite_path.text.get_extension().is_empty()
	
	if sprite_path.text.is_empty():
		printerr("Provided sprite path is empty.")
		return []
	
	if path_is_directory:
		if !importer.should_check_dir():
			printerr("Provided path is a directory.")
			return []
		
		print("Provided path is a directory. Converting every sprite in it...")
		
		var folder_sprites:PackedStringArray = DirAccess.get_files_at(sprite_path.text);
		
		for sprite:String in folder_sprites:
			sprite_name_list.append(sprite_path.text+sprite)
			#print("Found sprite: " + sprite_path.text+sprite)
	else:
		sprite_name_list.append(sprite_path.text)
	
	for sprite:String in sprite_name_list:
		if !FileAccess.file_exists(sprite) or !importer.get_texture_extensions().has("."+sprite.get_extension()):
			if !path_is_directory:
				printerr("Path \""+sprite+"\" doesn\'t appear to be a valid sprite type.")
			continue
		
		var texture:Texture2D = load(sprite)
		var atlas:String = sprite.get_basename()+importer.get_atlas_extension() if atlas_path.text.is_empty() else atlas_path.text
		
		print("Sprite Path: "+sprite+"\nAtlas Path: "+atlas)
		
		var sprite_data:ImporterSpriteData = ImporterSpriteData.new()
		sprite_data.texture = texture
		sprite_data.atlas_path = atlas
		sprite_data.check_dupped = check_dupped.button_pressed
		sprite_data.loop = loop.button_pressed
		sprite_data.fps = fps.value
		sprite_data.compress_output = compress_output.button_pressed
		sprite_list.append(sprite_data)
	
	return sprite_list

func add_to_tree():
	var sprite_list:Array[ImporterSpriteData] = process_sprite()
	
	if sprite_list.is_empty():
		printerr("Couldn't add to tree. No sprites found with the given path.")
		return
	
	for sprite_data:ImporterSpriteData in sprite_list:
		anim_tree.recieve_sprite(sprite_data)
	
	sprite_path.text = ""
	atlas_path.text = ""

func on_quick_import() -> void:
	var sprite_list:Array[ImporterSpriteData] = process_sprite()
	
	if sprite_list.is_empty():
		printerr("Couldn't import. No sprites found with the given path.")
		return
	
	# doing importer.convert_sprite(sprite_list)
	# would put all the sprites into the same SpriteFrames!!
	for sprite_data:ImporterSpriteData in sprite_list:
		var array:Array[ImporterSpriteData] = [sprite_data]
		importer.convert_sprite(array)

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

func folder_button(_focused_line_edit:String) -> void:
	focused_line_edit = NodePath(_focused_line_edit)
	
	var file_dialog:ConfirmationDialog = _make_file_dialog()
	add_child(file_dialog)
	file_dialog.popup_centered()
	file_dialog.connect("visibility_changed", func(): file_dialog.queue_free())

func file_selected(path:String) -> void:
	var line_edit = get_node(focused_line_edit)
	if line_edit is not LineEdit or line_edit == null:
		return
	var is_sprite_path = line_edit.get_meta("is_sprite_path", false)
	
	var valid_sprite_extension = find_closest_sprite_extension(path)
	
	if is_sprite_path:
		var texture_extensions:PackedStringArray = importer.get_texture_extensions()
		if !texture_extensions.has(path.get_extension()):
			path = path.get_basename() + valid_sprite_extension
			print(path)
		
		autofill_atlas_path(path)
	else:
		if "."+path.get_extension() != importer.get_atlas_extension():
			var atlas_path_predict:String = path.get_basename()+importer.get_atlas_extension()
			if FileAccess.file_exists(atlas_path_predict):
				path = atlas_path_predict
		
		autofill_sprite_path(path)
	
	line_edit.text = path;

func dir_selected(path:String) -> void:
	if !path.ends_with("/"):
		path += "/"
	
	var line_edit = get_node(focused_line_edit)
	if line_edit is LineEdit and line_edit != null:
		line_edit.text = path;
	autofill_atlas_path(path)

func find_closest_sprite_extension(path:String):
	var texture_extensions:PackedStringArray = importer.get_texture_extensions()
	for tex_extension:String in texture_extensions:
		if FileAccess.file_exists(path.get_basename() + tex_extension):
			return tex_extension

func autofill_sprite_path(new_path:String):
	if !new_path.get_extension().is_empty():
		var sprite_path_predict:String = new_path.get_basename() + find_closest_sprite_extension(new_path)
		
		if FileAccess.file_exists(sprite_path_predict):
			sprite_path.text = sprite_path_predict

func autofill_atlas_path(new_path:String):
	if importer.get_texture_extensions().has("."+new_path.get_extension()):
		var atlas_path_predict:String = new_path.get_basename() + importer.get_atlas_extension()
		
		if FileAccess.file_exists(atlas_path_predict):
			atlas_path.text = atlas_path_predict
