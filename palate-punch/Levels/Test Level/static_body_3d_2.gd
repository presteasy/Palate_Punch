extends StaticBody3D

func _ready() -> void:
	SignalManager.hit_landed.connect(_on_hit_landed)
	
func _on_hit_landed() -> void:
	print("hit landed")
