extends StaticBody3D

@export var item: InvItem
var player = null



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Global.player:
		player = body
		playerconnect()
		await get_tree().create_timer(0.1).timeout
		self.queue_free()
		
func playerconnect() -> void:
	player.collect(item)
