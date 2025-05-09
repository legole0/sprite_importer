extends Resource
class_name ImporterSpriteData

var texture:Texture2D
var atlas:XMLParser
var atlas_path:String
var loop:bool = false
var check_dupped:bool = true
var fps:int = 24
var compress_output:bool = false

func read_atlas(atlas_path:String):
	atlas = XMLParser.new()
	atlas.open(atlas_path)
	
	while atlas.read() == FAILED:
		printerr("Atlas failed loading at given path.")
		return

func get_animation_list() -> PackedStringArray:
	if atlas == null:
		read_atlas(atlas_path)
	
	var anim_list:PackedStringArray
	
	while atlas.read() == OK:
		if atlas.get_node_type() != XMLParser.NODE_ELEMENT: continue
		
		var node_name:String = atlas.get_node_name().to_lower()
		if node_name != "subtexture":
			continue
		
		anim_list.append(atlas.get_named_attribute_value("name").left(-4))
	
	print(anim_list)
	return anim_list
