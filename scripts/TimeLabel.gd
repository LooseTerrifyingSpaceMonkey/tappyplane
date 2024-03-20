extends Label

var time_elapsed := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta

func _format_seconds(time: float, use_milliseconds: bool)
