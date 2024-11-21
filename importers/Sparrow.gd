@tool
extends SpritesheetBase

func convert_sprite(tex:Texture2D, atlas_path:String):
	var atlas:XMLParser = XMLParser.new()
	atlas.open(atlas_path)
	var atlas_attributes:Dictionary[String,Variant] = {}
	for idx in range(atlas.get_attribute_count()):
		atlas_attributes[atlas.get_attribute_name(idx)] = atlas.get_attribute_value(idx)
	
	while atlas.read() == FAILED:
		printerr("Atlas failed loading at given path.")
		return
	
	var sprite_frames:SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	var dupped_frame_count:int = 0
	var last_frame:AtlasTexture = AtlasTexture.new()
	last_frame.atlas = tex
	
	while atlas.read() == OK:
		if atlas.get_node_type() == XMLParser.NodeType.NODE_TEXT: continue
		
		var anim_name:String = atlas_attributes["name"]
		
		if sprite_frames.has_animation(anim_name): return
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_loop(anim_name,loop.toggle_mode)
		sprite_frames.set_animation_speed(anim_name,fps.value)
		
		var frame_data:AtlasTexture
		frame_data.margin = Rect2(atlas_attributes["x"].to_float(),
			atlas_attributes["y"].to_float(),
			atlas_attributes["width"].to_float(),
			atlas_attributes["height"].to_float()
			)
		frame_data.filter_clip = true
		
		if check_dupped.toggle_mode and frame_data.margin == last_frame.margin:
			dupped_frame_count += 1
			frame_data.region = last_frame.region
		else:
			if atlas_attributes["frameX"] != null:
				frame_data.margin = Rect2(
					atlas_attributes["frameX"].to_float(),
					atlas_attributes["frameY"].to_float(),
					abs(atlas_attributes["frameWidth"].to_float() - frame_data.margin.size.x),
					abs(atlas_attributes["frameHeight"].to_float() - frame_data.margin.size.y)
					)
			last_frame = frame_data
			sprite_frames.add_frame(anim_name,frame_data)
		
	var save_path:String = tex.resource_path.get_basename()+(".tres" if compress_output else ".res")
	ResourceSaver.save(sprite_frames,save_path,ResourceSaver.FLAG_NONE if compress_output else ResourceSaver.FLAG_COMPRESS)
	if ResourceLoader.exists(save_path):
		print("SpriteFrame succesfully created at path: "+save_path+"\nFound "+str(dupped_frame_count)+" dupped frames.")
