class_name Boundary
extends Node2D


var Square = preload("res://Square.tscn")


func make_wall(start: Vector2, step: Vector2, num: int):
    for i in range(num):
        var coord := start + step * i
        var pos := coord * Globals.BLOCK_SIZE

        var child: Node2D = Square.instance()
        child.position = pos
        add_child(child)


func set_gravity(gravity: Array):
    for n in get_children():
        remove_child(n)
        n.queue_free()

    var half := Globals.GRID_HALF_WIDTH
    var width := Globals.GRID_WIDTH

    if gravity == [0, 1]:
        make_wall(Vector2(-half - 1, half),              Vector2(1, 0),      width + 1)
        make_wall(Vector2(half, half),                   Vector2(0, -1), 2 * width + 1)
        make_wall(Vector2(half, -width - half - 1),      Vector2(-1, 0),     width + 1)
        make_wall(Vector2(-half - 1, -width - half - 1), Vector2(0, 1),  2 * width + 1)
    elif gravity == [0, -1]:
        make_wall(Vector2(-half - 1, width + half),      Vector2(1, 0),      width + 1)
        make_wall(Vector2(half, width + half),           Vector2(0, -1), 2 * width + 1)
        make_wall(Vector2(half, -half - 1),              Vector2(-1, 0),     width + 1)
        make_wall(Vector2(-half - 1, -half - 1),         Vector2(0, 1),  2 * width + 1)
    elif gravity == [1, 0]:
        make_wall(Vector2(-width - half - 1, half),      Vector2(1, 0),  2 * width + 1)
        make_wall(Vector2(half, half),                   Vector2(0, -1),     width + 1)
        make_wall(Vector2(half, -half - 1),              Vector2(-1, 0), 2 * width + 1)
        make_wall(Vector2(-width - half - 1, -half - 1), Vector2(0, 1),      width + 1)
    elif gravity == [-1, 0]:
        make_wall(Vector2(-half - 1, half),              Vector2(1, 0),  2 * width + 1)
        make_wall(Vector2(width + half, half),           Vector2(0, -1),     width + 1)
        make_wall(Vector2(width + half, -half - 1),      Vector2(-1, 0), 2 * width + 1)
        make_wall(Vector2(-half - 1, -half - 1),         Vector2(0, 1),      width + 1)
