@tool
extends Node
class_name ImportUtils

static var addon_path:String

static func list_directory(path:String) -> Array[String]:
	var files:Array[String] = []
	var directory:DirAccess = DirAccess.open(path)
	
	if directory != null:
		directory.list_dir_begin()
		
		while true:
			var file:String = directory.get_next()
			
			if file == "":
				break
			elif not file.begins_with("."):
				files.append(file)
	return files
