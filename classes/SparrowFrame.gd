extends RefCounted
class_name SparrowFrame

var anim_name:String

var frame_idx:int
var frame_atlas:AtlasTexture = AtlasTexture.new()

var is_rotated:bool
var has_offset:bool
var frame_offset:Rect2
