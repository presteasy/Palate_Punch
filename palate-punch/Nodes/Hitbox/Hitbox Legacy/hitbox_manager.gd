extends Node3D
class_name HitboxManager


@export var owner_type: String = "player"
@export var use_owner_facing: bool = true

@onready var parent = get_parent()


func _ready() -> void:
	for c in get_children():
		if c is Hitbox:
			c.deactivate()
			
func apply_dir_of_parent() -> void:
	if parent == null:
		return
	var dir := 1
	if parent.has_method("get_facing_dir"):
		dir = parent.get_facing_dir()
	var i := 0
	while i < get_child_count():
		var c := get_child(i)
		if c is Hitbox:
			c.set_facing_dir(dir)
			c.owner_type = owner_type
		i += 1

func hb_on(name: String) -> void:
	var hb := get_node_or_null(name)
	if hb == null:
		return
	if hb is Hitbox:
		if use_owner_facing and parent and parent.has_method("get_facing_dir"):
			hb.set_facing_dir(owner.get_facing_dir())
			hb.owner_type = owner_type
			hb.activate()
			print("hb_on")

func hb_off(name: String) -> void:
	var hb := get_node_or_null(name)
	if hb and hb.has_method("deactivate"):
		hb.deactivate()
		print("hb_off")

func hb_off_all() -> void:
	for c in get_children():
		if c.has_method("deactivate"):
			c.deactivate()
			print("hb_off")
