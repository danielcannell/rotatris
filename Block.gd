class_name Block
extends Node2D

const BLOCK_SIZE: int = 32

var squares: Array; # of (int, int)
var color: int;  # Colors

# Global grid coordinate of the local (0, 0) position
var coord := [0, 0]


# shape is Globals.DefaultShapes
func from_shape(shape: int):
    self.color = randi() % Globals.Colors.size()

    if shape == Globals.DefaultShapes.I:
        self.squares = [[0,0], [0,1], [0,2], [0,3]]
    elif shape == Globals.DefaultShapes.J:
        self.squares = [[0,0], [0,1], [1,1], [2,1]]
    elif shape == Globals.DefaultShapes.L:
        self.squares = [[0,0], [0,1], [1,0], [2,0]]
    elif shape == Globals.DefaultShapes.O:
        self.squares = [[0,0], [0,1], [1,1], [1,0]]
    elif shape == Globals.DefaultShapes.Z:
        self.squares = [[0,0], [0,1], [1,1], [1,2]]
    elif shape == Globals.DefaultShapes.S:
        self.squares = [[1,0], [1,1], [0,1], [0,2]]
    elif shape == Globals.DefaultShapes.T:
        self.squares = [[0,0], [1,0], [1,1], [2,0]]
    else:
        assert(false)


func random():
    self.from_shape(randi() % Globals.DefaultShapes.size())


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
   self.position = BLOCK_SIZE * Vector2(self.coord[0], self.coord[1])
