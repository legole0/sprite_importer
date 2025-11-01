extends RefCounted
class_name SpriteImporter

## Name of the format. Will be used as the name of the tab.
func get_format_name() -> StringName:
	return ""

## Returns a bool depending if the atlas path is automatically determined or a custom path can be used.
func needs_atlas_path() -> bool:
	return true

## Returns the valid extensions for textures.
func get_texture_extensions() -> PackedStringArray:
	return [".png", ".webp"]

## Returns the extension for the atlas, usually .xml or .json.
func get_atlas_extension() -> String:
	return ""

## Whether or not every sprite in a given directory should be searched for sprites.
func should_check_dir() -> bool:
	return true
