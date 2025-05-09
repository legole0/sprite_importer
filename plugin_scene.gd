@tool
extends Node

@export_dir var tabs_path:String
@export var tab_container:TabContainer

func _enter_tree() -> void:
	var tabs : PackedStringArray = DirAccess.get_files_at(tabs_path)
	for tab in tabs:
		if !tab.ends_with(".tscn"):
			continue
		
		var new_tab:ImporterTab = load(tab).instantiate() as ImporterTab
		new_tab.name = new_tab.importer.get_format_name()
		tab_container.add_child(new_tab)
