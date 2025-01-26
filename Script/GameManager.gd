extends Node

var history_opened: bool
var saved_data: int
var close_load: bool = false
var backtrack_on: bool = false
var backtrack_name: String
var close_history: bool = false
var text_speed: float = 1.3
var saved_game: bool = false
var play_menu: bool = false
var persistent_children = {}
var BUBBLE_SCORE: int = 50

func save_child(child_node: Node, unique_id: String):
	
	# Ensure the directory exists
	DirAccess.make_dir_recursive_absolute("user://persistent_children/")
	
	# Create a packed scene for the child
	var packed_scene = PackedScene.new()
	packed_scene.pack(child_node)
	
	# Save with a unique identifier
	ResourceSaver.save(packed_scene, "user://persistent_children/%s.tscn" % unique_id)
	
	# Initialize metadata dictionary
	var metadata = {
		"name": child_node.name,
		"position": {
			"x": child_node.position.x,
			"y": child_node.position.y
		}
	}
	
	# Save and modify specific script variables
	var script = child_node.get_script()
	if script:
		# Dictionary to track variable modifications
		var script_metadata = {}
		
		# Example of modifying variables before saving
		if child_node.has_method("on_save_prepare"):
			# Call a custom method to prepare for saving
			child_node.on_save_prepare()
		
		# Variables you want to save and potentially modify
		var variables_to_save = [
			"has_saved",
			"saved_name"
		]
		
		for var_name in variables_to_save:
			# Check if the variable exists
			if child_node.get(var_name) != null:
				# Optional: Modify the variable before saving
				var current_value = child_node.get(var_name)
				var modified_value = modify_variable(var_name, current_value)
				
				# Set the modified value back to the node
				child_node.set(var_name, modified_value)
				
				# Save the modified value
				script_metadata[var_name] = modified_value
		
		# Only add script metadata if not empty
		if not script_metadata.is_empty():
			metadata["script_data"] = script_metadata
	
	# Store reference in dictionary
	persistent_children[unique_id] = {
		"path": "user://persistent_children/%s.tscn" % unique_id,
		"metadata": metadata
	}

# Function to modify variables before saving
func modify_variable(var_name: String, current_value):
	match var_name:
		"has_saved":
			return true
		"saved_name":
			return Dialogic.Save.get_latest_slot()

func save_all_children():
	var json_string = JSON.stringify(persistent_children)
	
	var file = FileAccess.open("user://persistent_children_index.json", FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("Could not open file to save persistent children")

# Check if child exists
func child_exists(unique_id: String) -> bool:
	if not unique_id in persistent_children:
		return false
	
	var scene_path = persistent_children[unique_id]["path"]
	return FileAccess.file_exists(scene_path)

# Load a specific child
func load_child(unique_id: String, parent_node: Node) -> Node:
	if not child_exists(unique_id):
		print("Persistent child %s does not exist" % unique_id)
		return null
	
	var scene_path = persistent_children[unique_id]["path"]
	var packed_scene = ResourceLoader.load(scene_path)
	var child_instance = packed_scene.instantiate()
	# Restore script variables if saved
	var metadata = persistent_children[unique_id]["metadata"]
	if metadata.has("script_data"):
		#if child_instance.has_method("set_new_var"):
				## If a setter method exists, use it
			#child_instance.call("set_new_var")
		for var_name in metadata["script_data"]:
			print(var_name)
			child_instance.set(var_name, metadata["script_data"][var_name])

	parent_node.add_child(child_instance)

	
	return child_instance

# Load all children
func load_all_children(parent_node: Node):
	if not FileAccess.file_exists("user://persistent_children_index.json"):
		return
	
	var file = FileAccess.open("user://persistent_children_index.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("JSON Parse Error: " + json.get_error_message())
		return
	
	# Get the parsed data
	persistent_children = json.get_data()
	
	# Filter out non-existent children
	var valid_children = {}
	for unique_id in persistent_children.keys():
		if child_exists(unique_id):
			load_child(unique_id, parent_node)
			valid_children[unique_id] = persistent_children[unique_id]
	
	# Update tracking to remove invalid entries
	persistent_children = valid_children
	save_all_children()

# Remove a specific persistent child
func remove_persistent_child(unique_id: String):
	if unique_id in persistent_children:
		# Delete the scene file
		var dir = DirAccess.open("user://persistent_children/")
		dir.remove(unique_id + ".tscn")
		
		# Remove from tracking dictionary
		persistent_children.erase(unique_id)
		
		# Update the index file
		save_all_children()

# Clear all persistent children
func clear_all_persistent_children():
	var dir = DirAccess.open("user://persistent_children/")
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			dir.remove(file_name)
		file_name = dir.get_next()
	
	persistent_children.clear()
	
	# Remove the index file
	if FileAccess.file_exists("user://persistent_children_index.json"):
		DirAccess.remove_absolute("user://persistent_children_index.json")
