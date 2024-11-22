@tool
extends SpritesheetBase

func convert_sprite(tex:Texture2D, atlas_path:String):
	var atlas:XMLParser = XMLParser.new()
	atlas.open(atlas_path)
	
	while atlas.read() == FAILED:
		printerr("Atlas failed loading at given path.")
		return
	
	var sprite_frames:SpriteFrames = SpriteFrames.new()
	sprite_frames.remove_animation("default")
	
	var dupped_frame_count:int = 0
	var last_frame:AtlasTexture = AtlasTexture.new()
	last_frame.atlas = tex
	
	await RenderingServer.frame_pre_draw
	
	var rotated_img:Image = tex.get_image()
	rotated_img.rotate_90(COUNTERCLOCKWISE)
	var rotated_tex:ImageTexture = ImageTexture.create_from_image(rotated_img)
	
	while atlas.read() == OK:
		if atlas.get_node_type() != XMLParser.NODE_ELEMENT: continue
		
		var node_name:String = atlas.get_node_name().to_lower()
		if node_name != "subtexture":
			continue
		
		var frame:SparrowFrame = SparrowFrame.new()
		# gets the animation name without the 4 characters (frame index)
		frame.anim_name = atlas.get_named_attribute_value("name").left(-4)
		frame.frame_atlas.atlas = tex
		
		if !sprite_frames.has_animation(frame.anim_name):
			sprite_frames.add_animation(frame.anim_name)
			sprite_frames.set_animation_loop(frame.anim_name,loop.button_pressed)
			sprite_frames.set_animation_speed(frame.anim_name,fps.value)
		
		frame.frame_atlas.margin = Rect2(
			atlas.get_named_attribute_value("x").to_float(),
			atlas.get_named_attribute_value("y").to_float(),
			atlas.get_named_attribute_value("width").to_float(),
			atlas.get_named_attribute_value("height").to_float()
			)
		frame.frame_atlas.filter_clip = true
		
		frame.is_rotated = atlas.get_named_attribute_value_safe("rotated") == "true"
		#if frame.is_rotated:
			#frame.frame_atlas.atlas = rotated_tex
		
		if check_dupped.button_pressed and frame.frame_atlas.margin == last_frame.margin:
			dupped_frame_count += 1
			frame.frame_atlas.region = last_frame.region
		else:
			frame.has_offset = atlas.has_attribute("frameX")
			if frame.has_offset:
				frame.frame_offset = Rect2(
					atlas.get_named_attribute_value_safe("frameX").to_float(),
					atlas.get_named_attribute_value_safe("frameY").to_float(),
					abs(atlas.get_named_attribute_value_safe("frameWidth").to_float() - frame.frame_atlas.margin.size.x),
					abs(atlas.get_named_attribute_value_safe("frameHeight").to_float() - frame.frame_atlas.margin.size.y)
					)
			last_frame = frame.frame_atlas
		sprite_frames.add_frame(frame.anim_name,frame.frame_atlas)
		
	var save_path:String = tex.resource_path.get_basename()+".tres" if !compress_output.button_pressed else ".res"
	ResourceSaver.save(sprite_frames,save_path,ResourceSaver.FLAG_NONE if !compress_output.button_pressed else ResourceSaver.FLAG_COMPRESS)
	if ResourceLoader.exists(save_path):
		print("SpriteFrame succesfully created at path: "+save_path+"\nFound "+str(dupped_frame_count)+" dupped frames.")
