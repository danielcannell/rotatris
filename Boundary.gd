class_name Boundary
extends Node2D


var Square = preload("res://Square.tscn")


var squares := {}


func collide(coord: Array):
    return self.squares.has(coord)


func make_wall(start: Array, step: Array, num: int):
    for i in range(num):
        var coord := [start[0] + step[0] * i, start[1] + step[1] * i]
        self.squares[coord] = true

        var pos := Vector2(coord[0], coord[1]) * Globals.BLOCK_SIZE

        var child: Node2D = Square.instance()
        child.position = pos
        add_child(child)


func set_gravity(gravity: Array):
    self.squares = {}
    for n in get_children():
        remove_child(n)
        n.queue_free()

    var half := Globals.GRID_HALF_WIDTH
    var width := Globals.GRID_WIDTH

    if gravity == [0, 1]:
        make_wall([-half - 1, half],              [1, 0],      width + 1)
        make_wall([half, half],                   [0, -1], 2 * width + 1)
        make_wall([half, -width - half - 1],      [-1, 0],     width + 1)
        make_wall([-half - 1, -width - half - 1], [0, 1],  2 * width + 1)
    elif gravity == [0, -1]:
        make_wall([-half - 1, width + half],      [1, 0],      width + 1)
        make_wall([half, width + half],           [0, -1], 2 * width + 1)
        make_wall([half, -half - 1],              [-1, 0],     width + 1)
        make_wall([-half - 1, -half - 1],         [0, 1],  2 * width + 1)
    elif gravity == [1, 0]:
        make_wall([-width - half - 1, half],      [1, 0],  2 * width + 1)
        make_wall([half, half],                   [0, -1],     width + 1)
        make_wall([half, -half - 1],              [-1, 0], 2 * width + 1)
        make_wall([-width - half - 1, -half - 1], [0, 1],      width + 1)
    elif gravity == [-1, 0]:
        make_wall([-half - 1, half],              [1, 0],  2 * width + 1)
        make_wall([width + half, half],           [0, -1],     width + 1)
        make_wall([width + half, -half - 1],      [-1, 0], 2 * width + 1)
        make_wall([-half - 1, -half - 1],         [0, 1],      width + 1)
