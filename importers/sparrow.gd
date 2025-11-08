@tool
extends SpriteImporter

func get_format_name() -> StringName:
	return "Sparrow"

func get_importer_data_class() -> String:
	return "SparrowImporterSpriteData"

func needs_atlas_path() -> bool:
	return true

func get_atlas_extension() -> String:
	return ".xml"

func convert_sprite(sprite_data_array:Array, disabled_anims:Array[String] = [], force_compress_output:bool = false) -> SpriteFrames:
	var sprite_frames:SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	var last_sprite_path:String
	var last_replaced_anim:String
	for sprite_data:ImporterSpriteData in sprite_data_array:
		sprite_data.read_atlas(sprite_data.atlas_path)
		var atlas:XMLParser = sprite_data.atlas
		
		var last_frame:AtlasTexture = AtlasTexture.new()
		last_frame.atlas = sprite_data.texture
		
		var frame_list:Array[SparrowFrame]
		while atlas.read() == OK:
			if atlas.get_node_type() != XMLParser.NODE_ELEMENT:
				continue
			
			if atlas.get_node_name().to_lower() != "subtexture":
				continue
			
			var frame:SparrowFrame = SparrowFrame.new()
			var anim_name:String = atlas.get_named_attribute_value("name").left(-4)
			if sprite_data.anim_aliases.has(anim_name):
				if anim_name != last_replaced_anim:
					print("Animation:" + anim_name + " replaced with: " + sprite_data.anim_aliases[anim_name])
				last_replaced_anim = anim_name
				anim_name = sprite_data.anim_aliases[anim_name]
				
			frame.anim_name = anim_name
			frame.atlas_texture.atlas = sprite_data.texture
			
			frame.atlas_texture.region = Rect2(
				atlas.get_named_attribute_value("x").to_float(),
				atlas.get_named_attribute_value("y").to_float(),
				atlas.get_named_attribute_value("width").to_float(),
				atlas.get_named_attribute_value("height").to_float()
				)
			frame.atlas_texture.filter_clip = true
			
			if atlas.has_attribute("frameX"):
				frame.atlas_margin = Rect2(
					-atlas.get_named_attribute_value_safe("frameX").to_float(),
					-atlas.get_named_attribute_value_safe("frameY").to_float(), 
					atlas.get_named_attribute_value_safe("frameWidth").to_float() - frame.atlas_texture.region.size.x,
					atlas.get_named_attribute_value_safe("frameHeight").to_float() - frame.atlas_texture.region.size.y
					)
			
			frame_list.append(frame)
		
		for frame:SparrowFrame in frame_list:
			var anim_name:String = frame.anim_name
			
			if disabled_anims.has(anim_name):
				continue
			
			if !sprite_frames.has_animation(anim_name):
				sprite_frames.add_animation(anim_name)
				sprite_frames.set_animation_loop(anim_name,sprite_data.loop)
				sprite_frames.set_animation_speed(anim_name,sprite_data.fps)
			
			if sprite_data.check_dupped and frame.atlas_texture.region == last_frame.region:
				frame.atlas_texture = last_frame
			
			if frame.atlas_margin != null:
				frame.atlas_texture.margin = frame.atlas_margin
			
			last_frame = frame.atlas_texture
			sprite_frames.add_frame(anim_name,frame.atlas_texture)
		last_sprite_path = sprite_data.texture.resource_path
	
	return sprite_frames
