@tool
extends Node

@export_dir var tabs_path:String
@export var tab_container:TabContainer

func _enter_tree() -> void:
	if ImportUtils.addon_path.is_empty():
		ImportUtils.addon_path = get_script().resource_path.get_base_dir()+"/"
	
	var tabs : PackedStringArray = DirAccess.get_files_at(tabs_path)
	for tab:String in tabs:
		if tab.get_extension() != "tscn":
			continue
		
		var tab_path:String = ImportUtils.addon_path + "tabs/" + tab
		var new_tab:ImporterTab = load(tab_path).instantiate() as ImporterTab
		tab_container.add_child(new_tab)
