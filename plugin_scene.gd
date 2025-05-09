@tool
extends Node

@export_dir var tabs_path:String
@export var tab_container:TabContainer

func _enter_tree() -> void:
	var tabs : PackedStringArray = DirAccess.get_files_at(tabs_path)
	for tab in tabs:
		if !tab.get_extension() == ".tscn":
			continue
		
		var new_tab:ImporterTab = load(tab).instantiate() as ImporterTab
		tab_container.add_child(new_tab)
