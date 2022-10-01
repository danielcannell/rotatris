class_name Boundary
extends Node2D

var texture = load("res://Art/box.png")
var center: Vector2 = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
    update_shape()


func make_wall(origin: Vector2, vec: Vector2, total: int):
    for i in range(total):
        var child := Sprite.new()
        child.position = origin + (Vector2(+0.5, -0.5) + vec * i) * Globals.BLOCK_SIZE
        child.texture = texture
        child.modulate = Globals.BACKGROUND_GREY
        add_child(child)


func update_shape():
    var half = Globals.GRID_HALF_WIDTH
    make_wall(center + Vector2(-half - 1, half) * Globals.BLOCK_SIZE, Vector2(1, 0), Globals.GRID_WIDTH+2)
    make_wall(center + Vector2(-half - 1, -half - 1) * Globals.BLOCK_SIZE, Vector2(1, 0), Globals.GRID_WIDTH+2)

    make_wall(center + Vector2(half, -half - 1) * Globals.BLOCK_SIZE, Vector2(0, 1), Globals.GRID_WIDTH+2)
    make_wall(center + Vector2(-half - 1, -half - 1) * Globals.BLOCK_SIZE, Vector2(0, 1), Globals.GRID_WIDTH+2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
