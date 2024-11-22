@tool
extends EditorPlugin

static var importer_scene:Control

func _enter_tree() -> void:
	ImportUtils.addon_path = get_script().resource_path.get_base_dir()+"/"
	importer_scene = load(ImportUtils.addon_path+"SpriteImporter.tscn").instantiate()
	#add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, importer_scene)
	#EditorInterface.get_editor_main_screen().add_child(importer_scene)
	add_control_to_bottom_panel(importer_scene, _get_plugin_name())
	
	print("Sprite Importer initialized correctly!")

func _exit_tree() -> void:
	remove_control_from_bottom_panel(importer_scene)
	importer_scene.queue_free()

func _has_main_screen():
	return true

func _toggle_visible(visible):
	if importer_scene:
		importer_scene.visible = !importer_scene.visible

func _get_plugin_name():
	return "Sprite Importer"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
