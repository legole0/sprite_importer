@tool
extends Tree
class_name ImporterAnimationTree

@export var tab:ImporterTab

@export_group("Icons")
@export var trash_icon:Texture2D

func recieve_sprite(sprite_data:ImporterSpriteData) -> void:
	if get_root() == null:
		var root:TreeItem = create_item()
	
	set_column_expand(0, false)
	
	var sprite:TreeItem = create_item(get_root())
	sprite.add_button(0, trash_icon)
	
	sprite.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	sprite.set_text(0, sprite_data.texture.resource_path.get_basename())
	sprite.set_expand_right(0,true)
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
	
	var disabled_anims:Array[String]
	var sprite_list:Array[ImporterSpriteData]
	
	for sprite:TreeItem in get_root().get_children():
		var sprite_data:ImporterSpriteData = sprite.get_metadata(0)
		if sprite_data is not ImporterSpriteData or sprite_data == null:
			printerr("Could not get sprite data.")
			return
		
		var repeated_sprite:bool = false
		for sprite_in_list:ImporterSpriteData in sprite_list:
			if sprite_in_list.atlas_path == sprite_data.atlas_path:
				repeated_sprite = true
				printerr("Skipping duplicated sprite: "+sprite_data.atlas_path.get_basename())
		
		if repeated_sprite:
			continue
		
		var sprite_tree_children:Array[TreeItem] = sprite.get_children()
		#sprite_data.read_atlas(sprite_data.atlas_path)
		var anim_list:PackedStringArray = sprite_data.animation_list
		for anim:TreeItem in sprite.get_children():
			if anim.is_checked(0):
				continue
			
			disabled_anims.append(anim.get_text(1))
		
		sprite_list.append(sprite_data)
	tab.importer.convert_sprite(sprite_list, disabled_anims)

func item_button_clicked(item:TreeItem, column:int, id:int, mouse_bttn_idx:int):
	var sprite_data:ImporterSpriteData = item.get_metadata(0)
	if sprite_data != null:
		print("Removed sprite: " + sprite_data.atlas_path.get_basename())
	item.free()
