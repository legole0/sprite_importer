extends Tree
class_name ImporterAnimationTree

@export var tab:ImporterTab

func recieve_sprite(sprite_data:ImporterSpriteData) -> void:
	if get_root() == null:
		var root:TreeItem = create_item()
	
	var sprite:TreeItem = create_item(get_root())
	sprite.set_text(0, sprite_data.texture.resource_path.get_basename())
	sprite.collapsed = true
	set_column_expand(0, false)
	sprite.set_expand_right(0,true)
	#sprite.add_button(0, checkbox_icon_pressed)
	sprite.set_metadata(0, sprite_data)
	
	for anim_name:String in sprite_data.animation_list:
		var anim:TreeItem = create_item(sprite)
		anim.set_cell_mode(0,TreeItem.CELL_MODE_CHECK)
		anim.set_checked(0, true)
		anim.set_editable(0, true)
		
		anim.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
		anim.set_text(1, anim_name)
		anim.set_editable(1, true)

func press_checkbox() -> void:
	pass

func remove_sprite(item:TreeItem) -> void:
	pass

func import_tree() -> void:
	if tab == null:
		printerr("ImporterTab not set in exported variables.")
		return
	
	if get_root() == null:
		printerr("Animation Tree is empty.")
		return
	
	var new_anim_names:Dictionary[String,String]
	var sprite_list:Array[ImporterSpriteData]
	
	for sprite:TreeItem in get_root().get_children():
		var sprite_data:ImporterSpriteData = sprite.get_metadata(0)
		if sprite_data is not ImporterSpriteData or sprite_data == null:
			printerr("Could not get sprite data.")
			return
		
		var sprite_tree_children:Array[TreeItem] = sprite.get_children()
		#sprite_data.read_atlas(sprite_data.atlas_path)
		var anim_list:PackedStringArray = sprite_data.animation_list
		for i in anim_list.size():
			var original_anim:String = anim_list[i]
			new_anim_names.keys().append(original_anim)
			
			new_anim_names[original_anim] = sprite_tree_children[i].get_text(0)
		
		sprite_list.append(sprite_data)
	
	tab.importer.convert_sprite(sprite_list, new_anim_names)

func item_button_clicked(item:TreeItem, column:int, id:int, mouse_bttn_idx:int):
	print("shit pressed ig")
	#remove_sprite(item)


func _on_multi_selected(item: TreeItem, column: int, selected: bool) -> void:
	print("shit pressed ig")
