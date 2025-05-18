@tool
extends SpriteImporter

func get_format_name() -> String:
	return "Sparrow"

func needs_atlas_path() -> bool:
	return true

func get_atlas_extension() -> String:
	return ".xml"

func convert_sprite(sprite_data_array:Array[ImporterSpriteData], disabled_anims:Array[String] = []):
	print(disabled_anims)
	var sprite_frames:SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	var dupped_frame_count:int = 0
	
	for sprite_data:ImporterSpriteData in sprite_data_array:
		sprite_data.read_atlas(sprite_data.atlas_path)
		var atlas:XMLParser = sprite_data.atlas
		
		var last_frame:AtlasTexture = AtlasTexture.new()
		last_frame.atlas = sprite_data.texture
		
		var frame_list:Array[SparrowFrame]
		while atlas.read() == OK:
			if atlas.get_node_type() != XMLParser.NODE_ELEMENT: continue
			
			var node_name:String = atlas.get_node_name().to_lower()
			if node_name != "subtexture":
				continue
			
			var frame:SparrowFrame = SparrowFrame.new()
			frame.anim_name = atlas.get_named_attribute_value("name").left(-4)
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
			
			if sprite_data_array.size() > 1:
				anim_name = sprite_data.atlas_path.get_file().get_basename() + "_" + anim_name
			
			if !sprite_frames.has_animation(anim_name):
				sprite_frames.add_animation(anim_name)
				sprite_frames.set_animation_loop(anim_name,sprite_data.loop)
				sprite_frames.set_animation_speed(anim_name,sprite_data.fps)
			
			if sprite_data.check_dupped and frame.atlas_texture.region == last_frame.region:
				dupped_frame_count += 1
				frame.atlas_texture = last_frame
			
			if frame.atlas_margin != null:
				frame.atlas_texture.margin = frame.atlas_margin
			
			last_frame = frame.atlas_texture
			sprite_frames.add_frame(anim_name,frame.atlas_texture)
	
	# GOTTA FIND A BETTER WAY AT HANDLING SAVING FOR MULTIPLE-ATLAS SPRITEFRAMES!!!
	# BUT FOR NOW IT JUST SAVES IT IN THE FIRST ONE'S PATH
	var sprite_path:String = sprite_data_array[0].texture.resource_path.get_basename()
	var compress_output:bool = sprite_data_array[0].compress_output
	var save_path:String = sprite_path+(".tres" if !compress_output else ".res")
	
	ResourceSaver.save(sprite_frames,save_path,ResourceSaver.FLAG_NONE if !compress_output else ResourceSaver.FLAG_COMPRESS)
	if ResourceLoader.exists(save_path):
		print("SpriteFrame succesfully created at path: "+save_path+"\nFound "+str(dupped_frame_count)+" dupped frames.")
