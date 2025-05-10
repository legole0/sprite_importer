extends Tree
class_name ImporterAnimationTree

@export_group("CheckBox")
@export var checkbox_icon_unpressed:Texture2D
@export var checkbox_icon_pressed:Texture2D

func recieve_sprite(sprite_data:ImporterSpriteData) -> void:
	if get_root() == null:
		var root:TreeItem = create_item()
	
	var sprite:TreeItem = create_item(get_root())
	sprite.set_text(0, sprite_data.texture.resource_path.get_basename())
	sprite.add_button(0,checkbox_icon_pressed)
	
	
	for anim_name:String in sprite_data.animation_list:
		var anim:TreeItem = create_item(sprite)
		anim.set_text(0, anim_name)
		anim.add_button(0,checkbox_icon_pressed)
		anim.set_editable(0, true)

func press_checkbox() -> void:
	pass

func remove_sprite() -> void:
	pass

func import_tree() -> void:
	pass
