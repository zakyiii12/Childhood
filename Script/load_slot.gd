extends Control
@onready var slots: HBoxContainer = $Slots
@onready var no_saved: TextEdit = $NoSaved
var persistent_children = {}

func _ready() -> void:
	GameManager.load_all_children(slots)

func _process(delta: float) -> void:
	if GameManager.saved_game:
		if slots.get_child_count() > 2:
			return

		var child_scene = preload("res://Scenes/saved_slot.tscn").instantiate()
		slots.add_child(child_scene)
		GameManager.saved_game = false

func _on_main_menu_btn_pressed() -> void:
	Dialogic.end_timeline()
	var current_scene = get_tree().current_scene
	if current_scene.name == "MainMenu":
		queue_free()
	else:
		GameManager.play_menu = true
		get_tree().paused = false
		
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
