extends Control


func _on_video_stream_player_finished() -> void:
	Dialogic.paused = false
	queue_free()
