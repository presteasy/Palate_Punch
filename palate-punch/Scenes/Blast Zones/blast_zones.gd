extends Area3D
class_name BlastZone




func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		print("You have died")
