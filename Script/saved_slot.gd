extends Control
@onready var slot: TextureButton = $Slot
@onready var date: TextEdit = $Date
@onready var delete: Button = $Delete
var saved_name: String
var has_saved: bool = false
var main_scene = preload("res://Scenes/main_game.tscn")

func _ready() -> void:
	if has_saved:
		print('Saved')
		print(saved_name)
	if !has_saved:
		var extra_info := {}
		extra_info["text"] = Dialogic.current_state_info["text"]
		extra_info["date"] = Time.get_datetime_string_from_system(false, true)
		saved_name = str(GameManager.saved_data)
		Dialogic.Save.save(saved_name, false, Dialogic.Save.ThumbnailMode.TAKE_AND_STORE, extra_info)

		slot.texture_normal = Dialogic.Save.get_slot_thumbnail(saved_name)
		slot.scale = Vector2(0.2, 0.2)
		slot.custom_minimum_size = Vector2(200, 100)
		slot.set_process_mode(Node.PROCESS_MODE_ALWAYS)

		date.text = extra_info["date"]

		delete.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		GameManager.saved_data += 1
		GameManager.save_child(self, str(Dialogic.Save.get_latest_slot()))
		GameManager.save_all_children()

func _on_slot_pressed() -> void:
	#var current_scene = get_tree().current_scene
	#print(get_parent().get_parent())
	#if current_scene.name == "load_slot":
		#var scene_instance = main_scene.instantiate()
		#get_parent().get_parent().get_parent().add_child(scene_instance)
		#get_parent().get_parent().queue_free()  # Remove current scene
		#Dialogic.Save.load(saved_name)
	#else:
	Dialogic.paused = false
	Dialogic.Save.load(saved_name)
	GameManager.close_load = true
	get_tree().paused = false

func _on_delete_pressed() -> void:
	GameManager.remove_persistent_child(saved_name)
	Dialogic.Save.delete_slot(saved_name)
	queue_free()
