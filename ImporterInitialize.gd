@tool
extends EditorPlugin

static var dockScene:Control

func _enter_tree() -> void:
	ImportUtils.addon_path = get_script().resource_path.get_base_dir()+"/"
	dockScene = load(ImportUtils.addon_path+"SpriteImporter.tscn").instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, dockScene)
	
	print("Sprite Importer initialized correctly!")

func _exit_tree() -> void:
	remove_control_from_docks(dockScene)
	dockScene.queue_free()
