extends Control
@onready var main_menu_anim: AnimationPlayer = $MainMenuAnim

func _ready() -> void:
	main_menu_anim.play("Begin")
	Dialogic.paused = true

func _process(delta: float) -> void:
	if GameManager.play_menu:
		print("play")
		main_menu_anim.play("Begin")
		GameManager.play_menu = false

func _on_start_game_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_game.tscn")

func _on_option_game_btn_pressed() -> void:
	var option_scene = preload("res://Scenes/settings.tscn").instantiate()
	get_tree().paused = true
	add_child(option_scene)

func _on_quit_game_btn_pressed() -> void:
	get_tree().quit()


func _on_credit_game_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/credit.tscn")
