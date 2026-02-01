extends Area2D

@export var speed := 200.0
@export var lifetime := 4.0

func _ready():
	# Auto destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	global_position += Vector2.RIGHT.rotated(global_rotation) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bullet") or body == owner:
		return
		
	if body.is_in_group("Player"):
		body.die()
	queue_free()  
