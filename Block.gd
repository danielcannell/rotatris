class_name Block
extends Node2D

const BLOCK_SIZE: int = 32

var squares: Array; # of (int, int)
var color: int;  # Colors

var shape: int = -1
var rot: int = 0

# Global grid coordinate of the local (0, 0) position
var coord := [0, 0]

# Unique block ID
var id := Globals.INVALID_BLOCK_ID

# Has this block been moved this turn?
var moved := false

# Last grid pos before a move
var _old_coord := [0, 0]
var _slide_t := 1.0
var _slide_time := 1.0


const SHAPES_ROTATIONS = {
    "line_h": [[-1,0], [0,0], [1,0], [2,0]],
    "line_v": [[1,-1], [1,0], [1,1], [1,2]],
    "box": [[0,0], [0,1], [1,1], [1,0]],
    "j_h_down": [[-1, 0], [0, 0], [1, 0], [1, 1]],
    "j_v_left": [[0, -1], [0, 0], [0, 1], [-1, 1]],
    "j_h_up": [[-1, 0], [0, 0], [1, 0], [-1, -1]],
    "j_v_right": [[0, -1], [0, 0], [0, 1], [1, -1]],
    "l_h_down": [[-1, 0], [0, 0], [1, 0], [-1, 1]],
    "l_v_left": [[0, -1], [0, 0], [0, 1], [-1, -1]],
    "l_h_up": [[-1, 0], [0, 0], [1, 0], [1, -1]],
    "l_v_right": [[0, -1], [0, 0], [0, 1], [1, 1]],
    "s_h":  [[-1, 1], [0, 1], [0, 0], [1, 0]],
    "s_v":  [[0, 0], [0, -1], [1, 0], [1, 1]],
    "t_down": [[-1, 0], [0, 0], [1, 0], [0, -1]],
    "t_left": [[0, -1], [0, 0], [0, 1], [-1, 0]],
    "t_up": [[-1, 0], [0, 0], [1, 0], [0, 1]],
    "t_right": [[0, -1], [0, 0], [0, 1], [1, 0]],
    "z_h":  [[-1, 0], [0, 0], [0, 1], [1, 1]],
    "z_v":  [[0, -1], [0, 0], [1, 0], [1, 1]],
}

const SHAPE_ROT_LOOKUP = {
    Globals.DefaultShapes.I: {
        0: SHAPES_ROTATIONS["line_v"],
        1: SHAPES_ROTATIONS["line_h"],
        2: SHAPES_ROTATIONS["line_v"],
        3: SHAPES_ROTATIONS["line_h"],
    },
    Globals.DefaultShapes.O: {
        0: SHAPES_ROTATIONS["box"],
        1: SHAPES_ROTATIONS["box"],
        2: SHAPES_ROTATIONS["box"],
        3: SHAPES_ROTATIONS["box"],
    },
    Globals.DefaultShapes.J: {
        0: SHAPES_ROTATIONS["j_h_down"],
        1: SHAPES_ROTATIONS["j_v_left"],
        2: SHAPES_ROTATIONS["j_h_up"],
        3: SHAPES_ROTATIONS["j_v_right"],
    },
    Globals.DefaultShapes.L: {
        0: SHAPES_ROTATIONS["l_h_down"],
        1: SHAPES_ROTATIONS["l_v_left"],
        2: SHAPES_ROTATIONS["l_h_up"],
        3: SHAPES_ROTATIONS["l_v_right"],
    },
    Globals.DefaultShapes.S: {
        0: SHAPES_ROTATIONS["s_h"],
        1: SHAPES_ROTATIONS["s_v"],
        2: SHAPES_ROTATIONS["s_h"],
        3: SHAPES_ROTATIONS["s_v"],
    },
    Globals.DefaultShapes.Z: {
        0: SHAPES_ROTATIONS["z_h"],
        1: SHAPES_ROTATIONS["z_v"],
        2: SHAPES_ROTATIONS["z_h"],
        3: SHAPES_ROTATIONS["z_v"],
    },
    Globals.DefaultShapes.T: {
        0: SHAPES_ROTATIONS["t_down"],
        1: SHAPES_ROTATIONS["t_left"],
        2: SHAPES_ROTATIONS["t_up"],
        3: SHAPES_ROTATIONS["t_right"],
    },
}


# shape is Globals.DefaultShapes
func from_shape(shape: int):
    self.color = randi() % Globals.Colors.size()
    self.shape = shape
    self.rot = randi() % 4
    self.squares = SHAPE_ROT_LOOKUP[self.shape][self.rot]


func random():
    self.from_shape(randi() % Globals.DefaultShapes.size())


func _init():
    self.id = Globals.allocate_block_id()


func _ready():
    update_shape()


func update_shape():
    for x in get_children():
        if x is Sprite:
            remove_child(x)
            x.queue_free()

    for pos in self.squares:
        var x: int = pos[0]
        var y: int = pos[1]

        var child := Sprite.new()
        child.position = Vector2(x, y) * BLOCK_SIZE
        child.texture = load("res://Art/box.png")
        child.modulate = Globals.ColorLookup[color]
        add_child(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if self._slide_t < 1.0:
        self._slide_t += delta / self._slide_time
    else:
        self._slide_t = 1.0

    self.update_position()


func update_position():
    # smoothly move the block to its target position
    var old_pos = BLOCK_SIZE * Vector2(self._old_coord[0], self._old_coord[1])
    var target_pos = BLOCK_SIZE * Vector2(self.coord[0], self.coord[1])
    self.position = lerp(old_pos, target_pos, self._slide_t)


func fill_grid(grid: Dictionary):
    for square in self.squares:
        var c := [self.coord[0] + square[0], self.coord[1] + square[1]]
        grid[c] = self.id


func erase_grid(grid: Dictionary):
    for square in self.squares:
        var c := [self.coord[0] + square[0], self.coord[1] + square[1]]
        grid.erase(c)


func can_move(grid: Dictionary, step: Array):
    var new_coord := [self.coord[0] + step[0], self.coord[1] + step[1]]

    for square in self.squares:
        var c := [new_coord[0] + square[0], new_coord[1] + square[1]]

        # Check if this square is occupied
        if grid.has(c) and grid[c] != self.id:
            return false

        # Check if this square is leaving the grid bounds
        if step[0] > 0 and c[0] >= Globals.GRID_HALF_WIDTH:
            return false
        if step[0] < 0 and c[0] < -Globals.GRID_HALF_WIDTH:
            return false
        if step[1] > 0 and c[1] >= Globals.GRID_HALF_WIDTH:
            return false
        if step[1] < 0 and c[1] < -Globals.GRID_HALF_WIDTH:
            return false

    return true


func move(grid: Dictionary, step: Array, smooth := true):
    self.erase_grid(grid)
    var new_coord = [self.coord[0] + step[0], self.coord[1] + step[1]]
    self._old_coord = self.coord
    self.coord = new_coord
    self._slide_t = 0.0
    self._slide_time = Globals.TIME_TO_MOVE_1_SQUARE
    self.fill_grid(grid)

    if not smooth:
        if step[0]:
            self._old_coord[0] = self.coord[0]
        if step[1]:
            self._old_coord[1] = self.coord[1]


func try_rotate(grid: Dictionary, rotate: int, gravity: Array):
    var new_rot = (self.rot + 1) % 4
    var new_squares = SHAPE_ROT_LOOKUP[self.shape][new_rot]

    for square in new_squares:
        var c := [self.coord[0] + square[0], self.coord[1] + square[1]]

        # Check if this square is occupied
        if grid.has(c) and grid[c] != self.id:
            return false

        # Check if this square is leaving the grid bounds
        if gravity[0] >= 0 and c[0] > Globals.GRID_HALF_WIDTH:
            return false
        if gravity[0] <= 0 and c[0] <= -Globals.GRID_HALF_WIDTH:
            return false
        if gravity[1] >= 0 and c[1] > Globals.GRID_HALF_WIDTH:
            return false
        if gravity[1] <= 0 and c[1] <= -Globals.GRID_HALF_WIDTH:
            return false

    self.erase_grid(grid)
    self.squares = new_squares
    self.rot = new_rot
    self.update_shape()
    self.fill_grid(grid)
