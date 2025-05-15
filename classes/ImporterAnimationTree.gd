extends Tree
class_name ImporterAnimationTree

@export var tab:ImporterTab

@export_group("CheckBox")
@export var checkbox_icon_unpressed:Texture2D
@export var checkbox_icon_pressed:Texture2D

func recieve_sprite(sprite_data:ImporterSpriteData) -> void:
	if get_root() == null:
		var root:TreeItem = create_item()
	
	var sprite:TreeItem = create_item(get_root())
	sprite.set_text(0, sprite_data.texture.resource_path.get_basename())
	
	#sprite.add_button(0, checkbox_icon_pressed)
	sprite.set_metadata(0, sprite_data)
	
	for anim_name:String in sprite_data.animation_list:
		var anim:TreeItem = create_item(sprite)
		anim.set_text(0, anim_name)
		#anim.add_button(0,checkbox_icon_pressed)
		anim.set_editable(0, true)

func press_checkbox() -> void:
	pass

func remove_sprite() -> void:
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
		for i in sprite_data.animation_list.size():
			var original_anim:String = sprite_data.animation_list[i]
			new_anim_names.keys().append(original_anim)
			
			new_anim_names[original_anim] = sprite_tree_children[i].get_text(0)
		
		sprite_list.append(sprite_data)
	
	tab.importer.convert_sprite(sprite_list, new_anim_names)

func item_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	var button_pressed:bool = item.get_button(column,id) == checkbox_icon_pressed
	item.set_button(column,id, checkbox_icon_unpressed if button_pressed else checkbox_icon_pressed)
