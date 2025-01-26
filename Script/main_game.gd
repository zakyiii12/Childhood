extends Control

@onready var bubble_meter: AnimatedSprite2D = $BgLayer/Layla/BubbleMeter
@onready var slots: HBoxContainer = $UI/Load/Slots
@onready var load: Control = $UI/load_slot
@onready var mini_game_layer: CanvasLayer = $MiniGameLayer

@onready var pause_btn: Button = $UI/Container/PauseBtn
@onready var save_btn: Button = $UI/Container/SaveBtn
@onready var load_btn: Button = $UI/Container/LoadBtn

const LAPANGAN = preload("res://Art/Background/Lapangan.png")
const PLACEHOLDER = preload("res://Art/Background/Placeholder.png")
const TAMAN = preload("res://Art/Background/Taman.png")
const RUANG_TAMU = preload("res://Art/Background/RuangTamu.png")
const DAPUR = preload("res://Art/Background/Dapur.png")

var mini_game_phase1 = preload("res://Scenes/MiniGamePhase1/mini_games_1.tscn").instantiate()
var is_fast: bool = false
var i: int = 1
var load_scene
func _ready() -> void:
	Dialogic.paused = false
	load_scene = preload("res://Scenes/load_slot.tscn").instantiate()
	set_process_unhandled_input(true)  
	add_child(Dialogic.start("Moment-1"))
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.Settings.text_speed = GameManager.text_speed
	$UI.add_child(load_scene)
	load_scene.visible = false

func _on_dialogic_signal(argument:String):
	if argument == "end":
		get_tree().quit()
	if argument == "stop_music":
		Dialogic.Audio.stop_all_sounds()
	if argument == "end_phase_1":
		var end_phase_1 = preload("res://Scenes/to_be_continue.tscn").instantiate()
		mini_game_layer.add_child(end_phase_1)
	if argument == "mini-game-phase-1":
		Dialogic.paused = true
		mini_game_layer.add_child(mini_game_phase1)
	if argument == "transition":
		var transition = preload("res://Scenes/transition.tscn").instantiate()
		Dialogic.paused = true
		mini_game_layer.add_child(transition)
	if argument == "+5":
		GameManager.BUBBLE_SCORE +=5
		evaluate_bubble_meter()
	if argument == "-5":
		GameManager.BUBBLE_SCORE -=5
		evaluate_bubble_meter()
	if argument == "lapangan":
		$BgLayer/Bg.texture = LAPANGAN
	if argument == "taman":
		$BgLayer/Bg.texture = TAMAN
	if argument == "ruang_tamu":
		$BgLayer/Bg.texture = RUANG_TAMU
	if argument == "dapur":
		$BgLayer/Bg.texture = DAPUR

func _process(delta: float) -> void:
	if GameManager.history_opened:
		pause_btn.disabled = true
		save_btn.disabled = true
		load_btn.disabled = true
	if !GameManager.history_opened:
		pause_btn.disabled = false
		save_btn.disabled = false
		load_btn.disabled = false
	if GameManager.close_load:
		load_scene.visible = false
		GameManager.close_load = false

func evaluate_bubble_meter() -> void:
	if GameManager.BUBBLE_SCORE == 0:
		bubble_meter.play("very_low")
	elif GameManager.BUBBLE_SCORE >= 5 and GameManager.BUBBLE_SCORE <= 40:
		bubble_meter.play("low")
	elif GameManager.BUBBLE_SCORE > 40 and GameManager.BUBBLE_SCORE <= 60:
		bubble_meter.play("balanced")
	elif GameManager.BUBBLE_SCORE > 60 and GameManager.BUBBLE_SCORE <= 95:
		bubble_meter.play("high")
	elif GameManager.BUBBLE_SCORE == 100:
		bubble_meter.play("very_high")

func _on_pause_pressed() -> void:
	var option_scene = preload("res://Scenes/settings.tscn").instantiate()
	get_tree().paused = true
	$UI.add_child(option_scene)

func _on_save_btn_pressed() -> void:
	GameManager.saved_game = true

func _on_load_btn_pressed() -> void:
	$TopLayer.visible = not $TopLayer.visible
	load_scene.visible = not load_scene.visible
	get_tree().paused = not get_tree().paused
