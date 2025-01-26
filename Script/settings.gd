extends Control

@onready var music_slider: HSlider = $VBoxContainer4/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer4/SFXContainer/SFXSlider
@onready var text_slider: HSlider = $VBoxContainer4/TextSpeedContainer/TextSlider

var music_name: String = "Music"
var sfx_name: String = "SFX"
var music_index: int
var sfx_index: int

func _ready() -> void:
	if AudioServer.get_bus_index(music_name) == -1:
		print("Bus name does not exist: %s" % music_name)
		return
	music_index = AudioServer.get_bus_index(music_name)
	music_slider.value_changed.connect(_on_music_value_changed)
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_index))

	if AudioServer.get_bus_index(sfx_name) == -1:
		print("Bus name does not exist: %s" % sfx_name)
		return
	sfx_index = AudioServer.get_bus_index(sfx_name)
	sfx_slider.value_changed.connect(_on_sfx_value_changed)
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))

	text_slider.value_changed.connect(_on_text_speed_value_changed)
	text_slider.value = GameManager.text_speed

func _on_text_speed_value_changed(value: float) -> void:
	Dialogic.Settings.text_speed = value
	GameManager.text_speed = value

func _on_music_value_changed(value: float) -> void:
	# Ensure the value is converted correctly before setting it
	AudioServer.set_bus_volume_db(music_index, linear_to_db(value))

func _on_sfx_value_changed(value: float) -> void:
	# Ensure the value is converted correctly before setting it
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(value))


func _on_windowed_btn_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_fullscreen_btn_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_back_btn_pressed() -> void:
	queue_free()
	get_tree().paused = false

func _on_main_menu_btn_pressed() -> void:
	Dialogic.end_timeline()
	await get_tree().create_timer(0.2).timeout
	var current_scene = get_tree().current_scene
	if current_scene.name == "MainMenu":
		queue_free()
	else:
		GameManager.play_menu = true
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
