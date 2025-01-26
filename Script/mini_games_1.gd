extends Control

@onready var child: AnimatedSprite2D = $Child
@onready var fail_count: Label = $FailCount
@onready var success_count: Label = $SuccessCount

var is_jumping: bool = false
var i: int = -1    
var j: int = 0
var hit_rope = false

func _on_child_hurt_box_area_entered(area: Area2D) -> void:
	i+=1
	fail_count.text = str(i)
	hit_rope = true

func success() -> void:
	if !hit_rope:
		j+=1
		success_count.text = str(j)

func reset_hit_rope() -> void:
	hit_rope = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and !is_jumping:
		var original_position = child.position
		child.play("jump")
		is_jumping = true

		var tween1 = create_tween()
		tween1.tween_property(child, "position:y", child.position.y - 100, 0.2)
		await tween1.finished

		var tween2 = create_tween()
		tween2.tween_property(child, "position", original_position, 0.2)
		await tween2.finished
		child.play("stand")
		is_jumping = false
	
	if success_count.text == str(20):
		Dialogic.VAR.set('result', true)
		$AnimationPlayer.play("end")

	if fail_count.text == str(20):
		Dialogic.VAR.set('result', false)
		$AnimationPlayer.play("end")

func end_game() -> void:
	Dialogic.paused = false
	queue_free()

func play_game() -> void:
	$MidiPlayer.play()

func _on_midi_player_midi_event(channel: Variant, event: Variant) -> void:
	if channel.number == 0:
		if event.type == 144:
			$AnimationPlayer.play("rope_anim")
